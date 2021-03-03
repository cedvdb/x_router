import 'package:flutter/widgets.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouter {
  XRouterDelegate delegate;
  XRouteInformationParser parser;
  XActivatedRouteBuilder _activatedRouteBuilder;
  // those static members are common for the root router and child routers
  static XRouterResolver _routerResolver;
  static XRouterStateNotifier _routerStateNotifier = XRouterStateNotifier();
  String name = '/';

  XRouter({
    @required List<XRoute> routes,
    List<XRouteResolver> resolvers = const [],
    XRoute notFound,
    // Function(XRouterState) onRouterStateChanges,
  }) {
    _routerStateNotifier = XRouterStateNotifier();
    _routerResolver = XRouterResolver(
      resolvers: resolvers,
      routes: routes,
      routerStateNotifier: _routerStateNotifier,
    );
    parser = XRouteInformationParser();
    delegate = XRouterDelegate(onNewRoute: (path) => _startNavigation(path));
    _routerStateNotifier.onResolvingStateChanges();
  }

  XRouter.child({
    @required List<XRoute> routes,
  }) {
    _routerStateNotifier
  }

  _onRoutingStateChanges() {
    final routerState = _routerStateNotifier.value;
    if (routerState.status == XStatus.navigation_start && name == '/') {
      return routingStateNotifier.startResolving();
    }
    if (routerState.status == XStatus.resolving_end) {
      return routingStateNotifier.startBuild();
    }
    if (routerState.status == XStatus.build_end) {
      return routingStateNotifier.endMavigation();
    }
  }
// pros of having the state accessed at the top,
// easier to dispose of the listeners
// easy to get an overview of what happens in the router class

// for the testing we can test that
// the activatedbuilder and resolver do resolve and build
// and that we eventually have navigation start, then navigation end

// in the case where the state is done here
//

  _onRouterStateChanges() {
    final status = _routerStateNotifier.value.status;
    if (status == XStatus.resolving_start) {
      return _resolveRoute();
    }
    if (status == XStatus.build_start) {
      return _buildRoute();
    }
    if (status == XStatus.navigation_end) {
      delegate.initBuild();
    }
  }

  _resolveRoute() {
    var resolved;
    for (var resolver in resolvers) {
      resolved = resolver.resolve(resolved, routes);
    }
    routerState.resolve(resolved);
  }

  _onRouteResolved() {
    if (routerState.status == XStatus.resolved) {
      final activatedRoute = _activatedRouteBuilder(_activatedRouteBuilder);
      routerState.setActivatedRoute(name, activatedRoute);
    }
  }

  _onNavigationEnd() {
    delegate.initBuild();
  }

  static goTo(String target) {
    _routerStateNotifier.startResolving(target);
  }

  dispose() {
    _routerStateNotifier.dispose();
  }
}
