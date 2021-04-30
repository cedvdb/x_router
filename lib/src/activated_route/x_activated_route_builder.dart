import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

import '../route/x_route.dart';

/// builds an Activated route when provided a `path`.
class XActivatedRouteBuilder {
  final List<XRoute> routes;
  final XRouterState _state = XRouterState.instance;
  final bool _isRoot;

  XActivatedRouteBuilder({
    required this.routes,
    required bool isRoot,
  }) : _isRoot = isRoot;

  XActivatedRoute build(String target) {
    _state.addEvent(ActivatedRouteBuildStart(isRoot: _isRoot, target: target));
    var matchings = _getOrderedPartiallyMatchingRoutes(target);
    var isFound = matchings.length > 0;
    if (!isFound) {
      matchings = [XSpecialRoutes.notFoundRoute];
    }
    final topRoute = matchings.removeAt(0);
    final upstack =
        matchings.map((route) => _toActivatedRoute(target, route)).toList();
    final activatedRoute = _toActivatedRoute(target, topRoute, upstack);
    _state.addEvent(ActivatedRouteBuildEnd(
        isRoot: _isRoot, activatedRoute: activatedRoute, target: target));
    return activatedRoute;
  }

  XActivatedRoute _toActivatedRoute(
    String path,
    XRoute route, [
    List<XActivatedRoute> upstack = const [],
  ]) {
    final parsed = route.parse(path);
    return XActivatedRoute(
      path: path,
      matchingRoute: route,
      effectivePath: parsed.matchingPath,
      parameters: parsed.parameters,
      upstack: upstack,
    );
  }

  List<XRoute> _getOrderedPartiallyMatchingRoutes(String path) {
    final matching = routes.where((route) => route.match(path)).toList()
      // ordered by length so childs are after
      ..sort((a, b) => a.path.length.compareTo(b.path.length));
    // when there is no builder we don't keep going
    return matching
        .takeWhile((route) => route.builder != null)
        .toList()
        // reverse so childs are in front
        .reversed
        .toList();
  }
}
