import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/state/x_routing_state.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';
import 'package:x_router/x_router.dart';

class ReactiveResolver extends ValueNotifier<bool> with XRouteResolver {
  String onFalse;
  String onTrue;
  ReactiveResolver({this.onFalse, this.onTrue}) : super(false);

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
      expect(
        notFoundResolver.resolve('/dashboard', routes),
        equals('/dashboard'),
      );
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
      final routingStateNotifier = XRoutingStateNotifier(
        initialState: XRoutingState(
          status: XStatus.navigation_start,
          target: '/',
        ),
      );
      XRouterResolver(
        resolvers: [
          XRedirectResolver(from: '/', to: '/other'),
          XRedirectResolver(from: '/other', to: '/not-found'),
          XNotFoundResolver(redirectTo: '/dashboard'),
        ],
        routes: routes,
        routingStateNotifier: routingStateNotifier,
      );
      routingStateNotifier.startResolving();
      expect(routingStateNotifier.value.status, equals(XStatus.resolving_end));
      expect(routingStateNotifier.value.resolved, equals('/dashboard'));
    });

    test(
      'Router Resolver should run resolve when resolver state changes',
      () {
        final routingStateNotifier = XRoutingStateNotifier(
          initialState: XRoutingState(
            status: XStatus.navigation_start,
            target: '/',
          ),
        );
        final resolver = ReactiveResolver(
          onTrue: '/true',
          onFalse: '/false',
        );
        resolver.value = false;
        XRouterResolver(
          resolvers: [resolver],
          routes: routes,
          routingStateNotifier: routingStateNotifier,
        );
        routingStateNotifier.startResolving();
        expect(
            routingStateNotifier.value.status, equals(XStatus.resolving_end));
        expect(routingStateNotifier.value.resolved, equals('/false'));
        resolver.value = true;
        expect(routingStateNotifier.value.resolved, equals('/true'));
      },
    );
  });
}
