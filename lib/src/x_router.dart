import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouter {
  // responsible of notifying when a new route needs to be resolved
  static final XRouterStateNotifier _routerStateNotifier =
      XRouterStateNotifier();
  // responsible of resolving a string path to (maybe) another
  final XRouteInformationParser parser = XRouteInformationParser();
  late final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
    isRoot: _isRoot,
    onDispose: dispose,
  );
  final List<XRoute> routes;
  late final XActivatedRouteBuilder _activatedRouteBuilder =
      XActivatedRouteBuilder(routes: routes);
  // whether this router is the root resolver and not a child / nested
  final bool _isRoot;
  static final List<XResolver> _resolvers = [];

  XRouter({
    required this.routes,
    List<XResolver> resolvers = const [],
    Function(XRouterState)? onRouterStateChanges,
  }) : _isRoot = true {
    _addRouteResolvers(routes);
    // the resolver will change the router state
    XRouterResolver(
      resolvers: resolvers,
      routes: routes,
      stateNotifier: _routerStateNotifier,
    );
    _addUserListener(onRouterStateChanges);
    // when the resolver has modified the states this runs
    _routerStateNotifier.addListener(_onRouterStateChanges);
  }

  XRouter.child({
    required this.routes,
  }) : _isRoot = false {
    _addRouteResolvers(routes);
    _onRouterStateChanges();
    _routerStateNotifier.addListener(_onRouterStateChanges);
  }

  static goTo(String target, {Map<String, String>? params}) {
    if (params != null) {
      target = XRouteParser(target).reverse(params);
    }
    // relative to current route
    if (target.startsWith('./')) {
      var resolved = _routerStateNotifier.value.resolved.split('/');
      resolved.removeLast();
      target = resolved.join('/') + target.substring(1);
    }
    _routerStateNotifier.startResolving(target);
  }

  dispose() {
    _routerStateNotifier.removeListener(_onRouterStateChanges);
  }

  // adds resolvers that are put on specific routes
  _addRouteResolvers(List<XRoute> routes) {
    // sorting the routes by path length so children are after parents.
    routes.sort((a, b) => a.path.length.compareTo(b.path.length));
    routes.forEach((route) => _resolvers.addAll(route.resolvers));
  }

  _onRouterStateChanges() {
    final state = _routerStateNotifier.value;
    final status = state.status;

    if (status == XStatus.resolved) {
      final activatedRoute = _activatedRouteBuilder.build(state.resolved);
      delegate.initBuild(activatedRoute);
    }
  }

  _addUserListener(Function(XRouterState)? onRouterStateChanges) {
    if (onRouterStateChanges != null) {
      _routerStateNotifier
          .addListener(() => onRouterStateChanges(_routerStateNotifier.value));
    }
  }
}
