import 'package:flutter/widgets.dart';
import 'package:route_parser/route_parser.dart';
import 'package:x_router/src/route/x_activated_route.dart';
import 'package:x_router/src/state/x_routing_state.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';

import 'x_route.dart';

/// builds an Activated route when provided a `path`.
class XActivatedRouteBuilder {
  final List<XRoute> routes;
  final XRoute notFoundRoute;
  final XRoutingStateNotifier routingStateNotifier;

  XActivatedRouteBuilder({
    @required this.routes,
    @required this.routingStateNotifier,
    @required this.notFoundRoute,
  }) {
    routingStateNotifier.addListener(_onRoutingStateChanges);
  }

  _onRoutingStateChanges() {
    if (routingStateNotifier.state.status == XStatus.build_start) {
      final activatedRoute =
          buildActivatedRoute(routingStateNotifier.state.directedTo);
      routingStateNotifier.build(activatedRoute);
    }
  }

  XActivatedRoute buildActivatedRoute(String path) {
    var matchings = _getOrderedPartiallyMatchingRoutes(path);
    var isFound =
        matchings.length > 0 && matchings.last.match(path, MatchType.exact);
    if (!isFound) {
      matchings = [notFoundRoute, ...matchings];
    }
    final topRoute = matchings.removeLast();
    final upstack =
        matchings.map((route) => _toActivatedRoute(path, route)).toList();
    return _toActivatedRoute(path, topRoute, upstack);
  }

  XActivatedRoute _toActivatedRoute(
    String path,
    XRoute route, [
    List<XActivatedRoute> upstack = const [],
  ]) {
    final parsed = route.parse(path);
    return XActivatedRoute(
      path: path,
      matcherRoute: route,
      matchingPath: parsed.matchingPath,
      parameters: parsed.parameters,
      upstack: upstack,
    );
  }

  List<XRoute> _getOrderedPartiallyMatchingRoutes(String path) {
    return routes
        .where((route) => route.builder != null && route.match(path))
        .toList()
          ..sort((a, b) => a.path.length.compareTo(b.path.length));
  }
}
