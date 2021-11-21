import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/route/x_default_routes.dart';
import 'package:x_router/src/state/x_router_state.dart';

import '../route/x_route.dart';
import 'x_activated_route_event.dart';

/// builds an Activated route when provided a `path`.
class XActivatedRouteBuilder {
  final List<XRoute> _routes;
  final XRouterState _state = XRouterState.instance;

  XActivatedRouteBuilder({
    required List<XRoute> routes,
  }) : _routes = routes;

  XActivatedRoute build(String target, {XPageBuilder? builder}) {
    var matchings = _getOrderedPartiallyMatchingRoutes(target);

    var isFound = matchings.length > 0;
    if (!isFound) {
      matchings = [XDefaultRoutes.notFoundRoute];
    }

    var topRoute = matchings.removeAt(0);

    if (builder != null) {
      topRoute = topRoute.copyWithBuilder(builder: builder);
    }

    final upstack = matchings
        .map((route) => _toActivatedRoute(
              target,
              route,
            ))
        .toList();

    final activatedRoute = _toActivatedRoute(
      target,
      topRoute,
      upstack,
    );
    return activatedRoute;
  }

  XActivatedRoute _toActivatedRoute(
    String path,
    XRoute route, [
    List<XActivatedRoute> upstack = const [],
  ]) {
    _state.addEvent(ActivatedRouteBuildStart(target: path));
    final parsed = route.parse(path);
    final activatedRoute = XActivatedRoute(
      path: path,
      route: route,
      effectivePath: parsed.matchingPath,
      parameters: parsed.parameters,
      upstack: upstack,
    );
    _state.addEvent(
        ActivatedRouteBuildEnd(activatedRoute: activatedRoute, target: path));
    return activatedRoute;
  }

  List<XRoute> _getOrderedPartiallyMatchingRoutes(String path) {
    final matching = _routes.where((route) => route.match(path)).toList()
      // ordered by length so childs are after
      ..sort((a, b) => a.path.length.compareTo(b.path.length));
    // when there is no builder we don't keep going
    return matching
        .toList()
        // reverse so childs are in front
        .reversed
        .toList();
  }
}
