import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../x_router.dart';

/// Holds information about the currently displayed route and its upstack
class XActivatedRoute with EquatableMixin {
  /// the requested path eg: `/team/123/route/44`
  final String requestedPath;

  /// the route pattern matched onto. eg: `Route(path: '/team/:id')`
  final XRoute route;

  /// the part of the path that is matching the deepest route. eg: `/team/123`
  final String effectivePath;

  /// parameters found in the path, eg:  for route pattern /team/:id and path /team/123
  /// parameters = { 'id': '123' }
  final Map<String, String> pathParams;

  /// parameters found in the path, eg: for /products?orderBy=creationDate
  /// queryParameters = { 'orderBy': 'creationDate' }
  final Map<String, String> queryParams;

  /// the parents matching routes, the upstack
  final List<XActivatedRoute> upstack;

  XActivatedRoute({
    required this.route,
    required this.requestedPath,
    required this.effectivePath,
    this.pathParams = const {},
    this.queryParams = const {},
    this.upstack = const [],
  });

  // Used as a placeholder at the start of the app to
  // not have a nullable and for testing
  factory XActivatedRoute.nulled([String path = '']) {
    return XActivatedRoute.forPath('');
  }

  factory XActivatedRoute.forPath(String path) {
    return XActivatedRoute(
      route: XRoute(
        path: path,
        builder: (ctx, params) => Container(),
      ),
      requestedPath: path,
      effectivePath: path,
    );
  }

  @override
  String toString() {
    return 'XActivatedRoute(path: $requestedPath, route: ${route.path}, effectivePath: $effectivePath, parameters: $pathParams, queryParameters: $queryParams, upstack.length: ${upstack.length})';
  }

  @override
  List<Object?> get props => [
        requestedPath,
        route,
        effectivePath,
        pathParams,
        queryParams,
        upstack,
      ];
}
