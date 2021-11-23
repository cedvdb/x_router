import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends XResolver<bool> {
  ReactiveResolver() : super(initialState: false);

  @override
  XResolverAction resolve(String target) {
    if (state == true) {
      return const Redirect('/true');
    }
    return const Redirect('/false');
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

    group('buil ins', () {
      test('RedirectResolver', () async {
        final redirectResolver = XRedirectResolver(from: '/', to: '/dashboard');
        final redirectWithParamsResolver =
            XRedirectResolver(from: '/products/:id', to: '/products/:id/info');
        expect(redirectResolver.resolve('/'),
            equals(const Redirect('/dashboard')));
        expect(redirectResolver.resolve('/other'),
            equals(const Redirect('/other')));
        expect(redirectWithParamsResolver.resolve('/products/123'),
            equals(const Redirect('/products/123/info')));
      });

      test(
          'NotFoundResolver should resolve to the route specified when not found',
          () async {
        final notFoundResolver =
            XNotFoundResolver(redirectTo: '/redirected', routes: routes);
        // found
        expect(
          notFoundResolver.resolve('/dashboard'),
          equals(const Next()),
        );
        // not found
        expect(
          notFoundResolver.resolve('/'),
          equals(const Redirect('/redirected')),
        );
        expect(
          notFoundResolver.resolve('/redirected'),
          equals(const Next()),
        );
        expect(
          notFoundResolver.resolve('/not-found'),
          equals(const Redirect('/redirected')),
        );
      });
    });

    test('XRouter resolver should resolve in chain', () async {
      final routerResolver = XRouterResolver(
        resolvers: [
          XRedirectResolver(from: '/', to: '/other'),
          XRedirectResolver(from: '/other', to: '/not-found'),
          XNotFoundResolver(redirectTo: '/dashboard', routes: routes),
        ],
        onStateChanged: () {},
      );
      expect(routerResolver.resolve('/'), equals(const Redirect('/dashboard')));
    });

    test(
      'Resolvers should notify when the state changes',
      () async {
        bool stateChanged = false;
        final reactiveResolver = ReactiveResolver();
        XRouterResolver(
          resolvers: [
            ReactiveResolver(),
          ],
          onStateChanged: () => stateChanged = true,
        );
        reactiveResolver.state = true;
        expect(stateChanged, isTrue);
      },
    );
  });
}
