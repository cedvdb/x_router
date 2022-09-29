import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/x_router.dart';

class ResolverBuilder with XResolver {
  XResolverAction Function(String target) resolveFn;

  ResolverBuilder(this.resolveFn);

  @override
  Future<XResolverAction> resolve(String target) async {
    return resolveFn(target);
  }
}

void main() {
  group('XRouterResolver', () {
    test('should go to next resolver when resolver returns Next', () async {
      int calls = 0;
      final nextResolver = ResolverBuilder((target) {
        ++calls;
        return const Next();
      });

      final routerResolver = XRouterResolver(
        onEvent: (_) {},
        resolvers: [nextResolver, nextResolver, nextResolver],
      );

      final result = await routerResolver.resolve('/');
      expect(result.target, equals('/'));
      expect(calls, equals(3));
    });

    test(
        'Should redirect and restart resolving process when resolver returns Redirect',
        () async {
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
      );

      final result = await routerResolver.resolve('/');
      expect(result.target, equals('/redirected'));
      expect(calls, equals(6));
    });
  });
}
