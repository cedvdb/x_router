import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends ValueNotifier<bool> with XResolver {
  ReactiveResolver() : super(false);

  @override
  XResolverAction resolve(String target) {
    return const Next();
  }
}

class ResolverBuilder with XResolver {
  XResolverAction Function(String target) resolveFn;

  ResolverBuilder(this.resolveFn);

  @override
  XResolverAction resolve(String target) {
    return resolveFn(target);
  }
}

void main() {
  group('XRouterResolver', () {
    test('should go to next resolver when resolver returns Next', () {
      int calls = 0;
      final nextResolver = ResolverBuilder((target) {
        ++calls;
        return const Next();
      });

      final routerResolver = XRouterResolver(
        onEvent: (_) {},
        resolvers: [nextResolver, nextResolver, nextResolver],
        onStateChanged: () {},
      );

      final result = routerResolver.resolve('/');
      expect(result.target, equals('/'));
      expect(calls, equals(3));

      routerResolver.dispose();
    });

    test(
        'Should redirect and restart resolving process when resolver returns Redirect',
        () {
      int calls = 0;

      final nextResolver = ResolverBuilder((target) {
        ++calls;
        return const Next();
      });

      final redirect = ResolverBuilder((target) {
        ++calls;
        if (target == '/') return const Redirect('/redirected');
        return const Next();
      });

      final routerResolver = XRouterResolver(
        onEvent: (_) {},
        resolvers: [nextResolver, nextResolver, redirect],
        onStateChanged: () {},
      );

      final result = routerResolver.resolve('/');
      expect(result.target, equals('/redirected'));
      expect(calls, equals(6));

      routerResolver.dispose();
    });

    test('should stop resolving process when resolver returns ByPass', () {
      int calls = 0;

      final nextResolver = ResolverBuilder((target) {
        ++calls;
        return const Next();
      });

      final bypass = ResolverBuilder((target) {
        ++calls;
        return const ByPass();
      });

      final redirect = ResolverBuilder((target) {
        ++calls;
        if (target == '/') return const Redirect('/redirected');
        return const Next();
      });

      final routerResolver = XRouterResolver(
        onEvent: (_) {},
        resolvers: [nextResolver, nextResolver, bypass, redirect],
        onStateChanged: () {},
      );

      final result = routerResolver.resolve('/');
      expect(result.target, equals('/'));
      expect(calls, equals(3));

      routerResolver.dispose();
    });

    test(
        'should stop resolving process when resolver returns Loading, and have a page builder',
        () {
      int calls = 0;

      final nextResolver = ResolverBuilder((target) {
        ++calls;
        return const Next();
      });

      final loading = ResolverBuilder((target) {
        ++calls;
        return Loading((_, __) => const CircularProgressIndicator());
      });

      final redirect = ResolverBuilder((target) {
        ++calls;
        if (target == '/') return const Redirect('/redirected');
        return const Next();
      });

      final routerResolver = XRouterResolver(
        onEvent: (_) {},
        resolvers: [nextResolver, nextResolver, loading, redirect],
        onStateChanged: () {},
      );

      final result = routerResolver.resolve('/');
      expect(result.target, equals('/'));
      expect(calls, equals(3));
      expect(result.builderOverride != null, isTrue);

      routerResolver.dispose();
    });

    test(
      'should notify when the state changes',
      () async {
        bool stateChanged = false;
        callback() => stateChanged = true;

        final reactiveResolver = ReactiveResolver();
        final routerResolver = XRouterResolver(
          onEvent: (_) {},
          resolvers: [reactiveResolver],
          onStateChanged: callback,
        );
        reactiveResolver.value = true;
        expect(stateChanged, isTrue);
        routerResolver.dispose();
      },
    );
  });
}
