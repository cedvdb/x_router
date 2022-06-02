import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../x_router.dart';

/// Holds information about the currently displayed route and its underneath
/// stack
class XNavigatedRoute with EquatableMixin {
  /// the route pattern matched onto. eg: `Route(path: '/team/:id')`
  final XRoute route;

  /// the requested path eg: `/team/123/route/44`
  final String requestedPath;

  /// the part of the path that is matching pattern
  final String matchingPath;

  /// the matching path for this route or any of its child router's routes
  final String effectivePath;

  /// parameters found in the path, eg:  for route pattern /team/:id and path /team/123
  /// parameters = { 'id': '123' }
  final Map<String, String> pathParams;

  /// parameters found in the path, eg: for /products?orderBy=creationDate
  /// queryParameters = { 'orderBy': 'creationDate' }
  final Map<String, String> queryParams;

  /// the parents matching routes, the poppableStack
  final List<XNavigatedRoute> poppableStack;

  /// the requested path matched against children route or if none, this route

  const XNavigatedRoute({
    required this.route,
    required this.requestedPath,
    required this.matchingPath,
    required this.effectivePath,
    this.pathParams = const {},
    this.queryParams = const {},
    this.poppableStack = const [],
  });

  // Used as a placeholder at the start of the app to
  // not have a nullable and for testing
  factory XNavigatedRoute.nulled([String path = '']) {
    return XNavigatedRoute.forPath('');
  }

  factory XNavigatedRoute.forPath(String path) {
    return XNavigatedRoute(
        route: XRoute(
          path: path,
          builder: (ctx, params) => Container(),
        ),
        requestedPath: path,
        matchingPath: path,
        effectivePath: path);
  }

  @override
  String toString() {
    return 'XActivatedRoute(path: $requestedPath, route: ${route.path}, effectivePath: $matchingPath, parameters: $pathParams, queryParameters: $queryParams, poppableStack.length: ${poppableStack.length})';
  }

  @override
  List<Object?> get props => [
        requestedPath,
        route,
        matchingPath,
        pathParams,
        queryParams,
        poppableStack,
      ];
}
