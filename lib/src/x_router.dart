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
  XRouterResolver _resolver;
  static XRouterStateNotifier _routerStateNotifier = XRouterStateNotifier();
  // whether this router is the root resolver and not a child / nested
  bool _isRoot;

  XRouter({
    @required List<XRoute> routes,
    List<XRouteResolver> resolvers = const [],
    XRoute notFound,
    // Function(XRouterState) onRouterStateChanges,
  }) {
    _isRoot = true;
    _routerStateNotifier = XRouterStateNotifier();
    _activatedRouteBuilder = XActivatedRouteBuilder(routes: routes);
    _resolver = XRouterResolver(
      resolvers: resolvers,
      routes: routes,
      //
    );
    parser = XRouteInformationParser();
    delegate = XRouterDelegate(
      onNewRoute: (path) => goTo(path),
    );
    _routerStateNotifier.addListener(_onRouterStateChanges);
  }

  XRouter.child({
    @required List<XRoute> routes,
  }) {
    _isRoot = false;
    _activatedRouteBuilder = XActivatedRouteBuilder(routes: routes);
    delegate = XRouterDelegate();
  }

  _onRouterStateChanges() {
    final state = _routerStateNotifier.value;
    final status = state.status;

    if (status == XStatus.resolving && _isRoot) {
      final resolved = _resolver.resolve(state.target);
      _routerStateNotifier.endResolving(resolved);
    }

    if (status == XStatus.resolved) {
      final activatedRoute = _activatedRouteBuilder.build(state.resolved);
      delegate.initBuild(activatedRoute);
    }
  }

  static goTo(String target) {
    _routerStateNotifier.startResolving(target);
  }

  dispose() {
    _routerStateNotifier.dispose();
  }
}
