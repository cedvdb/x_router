import 'package:flutter/widgets.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';

import '../route/x_route.dart';

/// builds an Activated route when provided a `path`.
class XActivatedRouteBuilder {
  final List<XRoute> routes;

  XActivatedRouteBuilder({
    @required this.routes,
  });

  XActivatedRoute build(String path) {
    var matchings = _getOrderedPartiallyMatchingRoutes(path);
    var isFound = matchings.length > 0;
    if (!isFound) {
      matchings = [XSpecialRoutes.notFoundRoute, ...matchings];
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
      matchingRoute: route,
      effectivePath: parsed.matchingPath,
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
