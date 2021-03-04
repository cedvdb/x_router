import 'package:flutter/widgets.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouter {
  static final XRouterStateNotifier _routerStateNotifier =
      XRouterStateNotifier();
  final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
  );
  final XRouteInformationParser parser = XRouteInformationParser();
  XActivatedRouteBuilder _activatedRouteBuilder;
  // responsible of resolving a string path to (maybe) another
  XRouterResolver _resolver;
  // whether this router is the root resolver and not a child / nested
  bool _isRoot;

  XRouter({
    @required List<XRoute> routes,
    List<XRouteResolver> resolvers = const [],
    XRoute notFound,
    Function(XRouterState) onRouterStateChanges,
  }) {
    _isRoot = true;
    _activatedRouteBuilder = XActivatedRouteBuilder(routes: routes);
    _resolver = XRouterResolver(
      resolvers: resolvers,
      routes: routes,
      onStateChanges: () => goTo(_routerStateNotifier.value.resolved),
    );
    _routerStateNotifier.addListener(_onRouterStateChanges);
    if (onRouterStateChanges != null) {
      _routerStateNotifier
          .addListener(() => onRouterStateChanges(_routerStateNotifier.value));
    }
  }

  XRouter.child({
    @required List<XRoute> routes,
  }) {
    _isRoot = false;
    _activatedRouteBuilder = XActivatedRouteBuilder(routes: routes);
    _onRouterStateChanges();
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
    _resolver.dispose();
    _routerStateNotifier.dispose();
  }
}
