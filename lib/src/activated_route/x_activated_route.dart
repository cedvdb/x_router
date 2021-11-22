import 'package:flutter/widgets.dart';

import '../../x_router.dart';

/// Holds information about the currently displayed route and its upstack
class XActivatedRoute {
  /// the path of the route. eg: `/team/123/route/44`
  final String path;

  /// the route pattern matched onto. eg: `Route(path: '/team/:id')`
  final XRoute route;

  /// the part of the path that is matching. eg: `/team/123`
  final String effectivePath;

  /// parameters found in the path, eg:  for route pattern /team/:id and path /team/123
  /// parameters = { 'id': '123' }
  final Map<String, String> pathParameters;

  /// parameters found in the path, eg: for /products?orderBy=creationDate
  /// queryParameters = { 'orderBy': 'creationDate' }
  final Map<String, String> queryParameters;

  /// the parents matching routes, the upstack
  final List<XActivatedRoute> upstack;

  XActivatedRoute({
    required this.path,
    required this.route,
    required this.effectivePath,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.upstack = const [],
  });

  // Used as a placeholder at the start of the app to
  // not have a nullable
  factory XActivatedRoute.nulled() {
    return XActivatedRoute(
      route: XRoute(
        path: '',
        builder: (ctx, params) => Container(),
      ),
      path: '',
      effectivePath: '',
    );
  }

  @override
  String toString() {
    return 'XActivatedRoute(path: $path, route: ${route.path}, effectivePath: $effectivePath, parameters: $pathParameters, queryParameters: $queryParameters, upstack.length: ${upstack.length})';
  }
}
