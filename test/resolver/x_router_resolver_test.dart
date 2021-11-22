import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends XResolver<bool> {
  ReactiveResolver() : super(initialState: false);

  @override
  Future<String> resolve(String target) async {
    if (state == true) {
      return '/true';
    }
    return '/false';
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
    ];

    test('RedirectResolver', () async {
      final redirectResolver = XRedirectResolver(from: '/', to: '/dashboard');
      final redirectWithParamsResolver =
          XRedirectResolver(from: '/products/:id', to: '/products/:id/info');
      expect(redirectResolver.resolve('/'), equals('/dashboard'));
      expect(redirectResolver.resolve('/other'), equals('/other'));
      expect(redirectWithParamsResolver.resolve('/products/123'),
          equals('/products/123/info'));
    });

    test(
        'NotFoundResolver should resolve to the route specified when not found',
        () async {
      final notFoundResolver =
          XNotFoundResolver(redirectTo: '/redirected', routes: routes);
      // found
      expect(
        notFoundResolver.resolve('/dashboard'),
        equals('/dashboard'),
      );
      // not found
      expect(
        notFoundResolver.resolve('/'),
        equals('/redirected'),
      );
      expect(
        notFoundResolver.resolve('/redirected'),
        equals('/redirected'),
      );
      expect(
        notFoundResolver.resolve('/not-found'),
        equals('/redirected'),
      );
    });

    test('XRouter resolver should resolve in chain', () async {
      final routerResolver = XRouterResolver(
        onStateChanged: () {},
      )..addResolvers([
          XRedirectResolver(from: '/', to: '/other'),
          XRedirectResolver(from: '/other', to: '/not-found'),
          XNotFoundResolver(redirectTo: '/dashboard', routes: routes),
        ]);
      expect(await routerResolver.resolve('/'), equals('/dashboard'));
    });

    test(
      'Resolvers should notify when the state changes',
      () async {
        var stateChangeCalled = false;
        final resolver = ReactiveResolver();
        final routerResolver = XRouterResolver(
          onStateChanged: () {
            stateChangeCalled = true;
          },
        )..addResolvers([resolver]);
        resolver.state = true;
        // state change is async
        await Future.value(true);
        expect(stateChangeCalled, equals(true));
        expect(routerResolver.resolve('/target'), equals('/true'));
      },
    );

    test(
      'Route Resolvers should run only on their path',
      () async {
        final resolver = ReactiveResolver()..state = true;
        final routerResolver = XRouterResolver(
          onStateChanged: () {},
        )..addRoutesResolvers([
            XRoute(
              path: '/route',
              builder: (_, __) => Container(),
              resolvers: [resolver],
            )
          ]);

        expect(routerResolver.resolve('/route'), equals('/true'));
        expect(routerResolver.resolve('/route/child'), equals('/true'));
        expect(routerResolver.resolve('/not-route'), isNot('/true'));
      },
    );
  });
}
