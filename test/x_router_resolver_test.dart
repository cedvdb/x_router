import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends ValueNotifier<bool> with XRouteResolver {
  String onFalse;
  String onTrue;
  ReactiveResolver({
    required this.onFalse,
    required this.onTrue,
  }) : super(false);

  @override
  String resolve(String target, List<XRoute> routes) {
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
    ];

    test('RedirectResolver', () {
      final redirectResolver = XRedirectResolver(from: '/', to: '/dashboard');
      expect(redirectResolver.resolve('/', routes), equals('/dashboard'));
      expect(redirectResolver.resolve('/other', routes), equals('/other'));
    });

    test(
        'NotFoundResolver should resolve to the route specified when not found',
        () {
      final notFoundResolver = XNotFoundResolver(redirectTo: '/redirected');
      // found
      expect(
        notFoundResolver.resolve('/dashboard', routes),
        equals('/dashboard'),
      );
      // not found
      expect(
        notFoundResolver.resolve('/', routes),
        equals('/redirected'),
      );
      expect(
        notFoundResolver.resolve('/redirected', routes),
        equals('/redirected'),
      );
      expect(
        notFoundResolver.resolve('/not-found', routes),
        equals('/redirected'),
      );
    });

    test('XRouter resolver should resolve in chain', () {
      final stateNotifier = XRouterStateNotifier();
      XRouterResolver(
        resolvers: [
          XRedirectResolver(from: '/', to: '/other'),
          XRedirectResolver(from: '/other', to: '/not-found'),
          XNotFoundResolver(redirectTo: '/dashboard'),
        ],
        routes: routes,
        stateNotifier: stateNotifier,
      );
      stateNotifier.startResolving('/');
      expect(stateNotifier.value.status, equals(XStatus.resolved));
      expect(stateNotifier.value.resolved, equals('/dashboard'));
    });

    test(
      'Router Resolver should run resolve when resolver state changes',
      () {
        final stateNotifier = XRouterStateNotifier();
        final resolver = ReactiveResolver(
          onTrue: '/true',
          onFalse: '/false',
        );
        resolver.value = false;
        XRouterResolver(
          resolvers: [resolver],
          routes: routes,
          stateNotifier: stateNotifier,
        );
        stateNotifier.startResolving('/');
        expect(stateNotifier.value.status, equals(XStatus.resolved));
        expect(stateNotifier.value.resolved, equals('/false'));
        resolver.value = true;
        expect(stateNotifier.value.resolved, equals('/true'));
      },
    );
  });
}
