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
          buildActivatedRoute(routingStateNotifier.state.redirection);
      routingStateNotifier.build(activatedRoute);
    }
  }

  XActivatedRoute buildActivatedRoute(String path) {
    var matchings = _getOrderedMatchingRoutes(path);
    var isFound = matchings.first.match(path, MatchType.exact);
    if (!isFound) {
      matchings = [notFoundRoute, ...matchings];
    }
    final top = matchings.removeLast();
    // shortcut is taken here to not parse the route for each parent
    final params = top.parse(path).parameters;

    return XActivatedRoute(
      path: path,
      matcherRoute: top,
      parameters: top.parse(path).parameters,
      parents: matchings
          .map(
            (route) => XActivatedRoute(
              matcherRoute: route,
              parameters: params,
              path: path,
            ),
          )
          .toList(),
    );
  }

  List<XRoute> _getOrderedMatchingRoutes(String path) {
    return routes
        .where((route) => route.builder != null && route.match(path))
        .toList()
          ..sort((a, b) => a.path.length.compareTo(b.path.length));
  }
}
