import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends ValueNotifier<bool> with XResolver {
  String onFalse;
  String onTrue;
  ReactiveResolver({
    required this.onFalse,
    required this.onTrue,
  }) : super(false);

  @override
  Future<String> resolve(String target) async {
    if (value) {
      return onTrue;
    } else {
      return onFalse;
    }
  }
}

void main() {
  group('Resolvers', () {
    final routes = [
      XRoute(
        path: '/dashboard',
        builder: (context, params) => Container(),
      ),
      XRoute(
        path: '/redirected',
        builder: (context, params) => Container(),
      ),
      XRoute(
        path: '/route-resolvers',
        builder: (context, params) => Container(),
        resolvers: [
          XSimpleResolver((target) async {
            return '/success';
          }),
        ],
      )
    ];

    test('RedirectResolver', () async {
      final redirectResolver = XRedirectResolver(from: '/', to: '/dashboard');
      expect(await redirectResolver.resolve('/'), equals('/dashboard'));
      expect(await redirectResolver.resolve('/other'), equals('/other'));
    });

    test(
        'NotFoundResolver should resolve to the route specified when not found',
        () async {
      final notFoundResolver =
          XNotFoundResolver(redirectTo: '/redirected', routes: routes);
      // found
      expect(
        await notFoundResolver.resolve('/dashboard'),
        equals('/dashboard'),
      );
      // not found
      expect(
        await notFoundResolver.resolve('/'),
        equals('/redirected'),
      );
      expect(
        await notFoundResolver.resolve('/redirected'),
        equals('/redirected'),
      );
      expect(
        await notFoundResolver.resolve('/not-found'),
        equals('/redirected'),
      );
    });

    test('XRouter resolver should resolve in chain', () async {
      final routerResolver = XRouterResolver(
        resolvers: [
          XRedirectResolver(from: '/', to: '/other'),
          XRedirectResolver(from: '/other', to: '/not-found'),
          XNotFoundResolver(redirectTo: '/dashboard', routes: routes),
        ],
        routes: routes,
        stateNotifier: XRouterStateNotifier(),
      );
      expect(await routerResolver.resolve('/'), equals('/dashboard'));
    });

    test(
      'Router Resolver should run resolve when resolver state changes',
      () async {
        final stateNotifier = XRouterStateNotifier();
        final resolver = ReactiveResolver(
          onTrue: '/true',
          onFalse: '/false',
        );
        resolver.value = false;
        XRouterResolver(
          resolvers: [resolver],
          stateNotifier: stateNotifier,
        );
        stateNotifier.startResolving('/');
        await Future.delayed(Duration(milliseconds: 100));
        expect(stateNotifier.value.status, equals(XStatus.resolved));
        expect(stateNotifier.value.resolved, equals('/false'));
        resolver.value = true;
        await Future.delayed(Duration(milliseconds: 100));
        expect(stateNotifier.value.resolved, equals('/true'));
      },
    );

    test(
      'Routes Resolvers should run only on their path',
      () async {
        final stateNotifier = XRouterStateNotifier();

        XRouterResolver(stateNotifier: stateNotifier, routes: routes);

        stateNotifier.startResolving('/route-resolvers');
        await Future.delayed(Duration(milliseconds: 100));
        expect(stateNotifier.value.status, equals(XStatus.resolved));
        expect(stateNotifier.value.resolved, equals('/success'));
        stateNotifier.startResolving('/');
        await Future.delayed(Duration(milliseconds: 100));
        expect(stateNotifier.value.resolved, equals('/'));
      },
    );
  });
}
