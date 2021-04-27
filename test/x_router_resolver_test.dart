import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/state/x_router_state.dart';
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
        onStateChanged: () {},
        routerState: XRouterState(),
      );
      routerResolver.addResolvers([
        XRedirectResolver(from: '/', to: '/other'),
        XRedirectResolver(from: '/other', to: '/not-found'),
        XNotFoundResolver(redirectTo: '/dashboard', routes: routes),
      ]);
      expect(await routerResolver.resolve('/'), equals('/dashboard'));
    });

    test(
      'Router Resolver should notify when the state changes',
      () async {
        var stateChangeCalled = false;
        final routerResolver = XRouterResolver(
          onStateChanged: () {
            stateChangeCalled = true;
          },
          routerState: XRouterState(),
        );
        final resolver = ReactiveResolver();
        routerResolver.addResolvers([resolver]);
        resolver.state = true;
        await Future.delayed(Duration(milliseconds: 100));
        expect(stateChangeCalled, equals(true));
        expect(await resolver.resolve('/target'), equals('/true'));
      },
    );

    test(
      'Routes Resolvers should run only on their path',
      () async {
        final routerResolver =
            XRouterResolver(onStateChanged: () {}, routerState: XRouterState());
        final resolver = ReactiveResolver()..state = true;
        routerResolver.addRouteResolvers([
          XRoute(
            path: '/route',
            builder: (_, __) => Container(),
            resolvers: [resolver],
          ),
        ]);

        expect(await routerResolver.resolve('/route'), equals('/true'));
        expect(await routerResolver.resolve('/route/child'), equals('/true'));
        expect(await routerResolver.resolve('/not-route'), isNot('/true'));
      },
    );
  });
}
