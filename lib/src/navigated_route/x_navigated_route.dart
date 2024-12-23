import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../x_router.dart';

/// Holds information about the currently displayed route and its underneath
/// stack
class NavigatedRoute with EquatableMixin {
  /// the route pattern matched onto. eg: `Route(path: '/team/:id')`
  final XRoute route;

  /// the requested path eg: `/team/123/route/44`
  final String requestedPath;

  /// the part of the path that is matching pattern
  final String matchingPath;

  /// the path that matches the deepest child route
  String get effectivePath {
    if (child != null) return child!.effectivePath;
    return matchingPath;
  }

  /// parameters found in the path, eg:  for route pattern /team/:id and path /team/123
  /// parameters = { 'id': '123' }
  final Map<String, String> pathParams;

  /// parameters found in the path, eg: for /products?orderBy=creationDate
  /// queryParameters = { 'orderBy': 'creationDate' }
  final Map<String, String> queryParams;

  /// the parents matching routes, the poppableStack
  final List<NavigatedRoute> poppableStack;

  /// navigated route from a child router
  final NavigatedRoute? child;

  const NavigatedRoute({
    required this.route,
    required this.requestedPath,
    required this.matchingPath,
    this.child,
    this.pathParams = const {},
    this.queryParams = const {},
    this.poppableStack = const [],
  });

  // Used as a placeholder at the start of the app to
  // not have a nullable and for testing
  factory NavigatedRoute.nulled([String path = '']) {
    return NavigatedRoute.forPath('');
  }

  factory NavigatedRoute.forPath(String path) {
    return NavigatedRoute(
      route: XRoute(
        path: path,
        builder: (ctx, params) => Container(),
      ),
      requestedPath: path,
      matchingPath: path,
    );
  }

  @override
  String toString() {
    return 'XActivatedRoute(route: ${route.path}, matchingPath: $matchingPath, requestedPath: $requestedPath, parameters: $pathParams, queryParameters: $queryParams, poppableStack.length: ${poppableStack.length}, child: $child)';
  }

  @override
  List<Object?> get props => [
        route,
        requestedPath,
        matchingPath,
        pathParams,
        queryParams,
        poppableStack,
        child,
      ];

  NavigatedRoute copyWith({
    XRoute? route,
    String? requestedPath,
    String? matchingPath,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    List<NavigatedRoute>? poppableStack,
    NavigatedRoute? child,
  }) {
    return NavigatedRoute(
      route: route ?? this.route,
      requestedPath: requestedPath ?? this.requestedPath,
      matchingPath: matchingPath ?? this.matchingPath,
      pathParams: pathParams ?? this.pathParams,
      queryParams: queryParams ?? this.queryParams,
      poppableStack: poppableStack ?? this.poppableStack,
      child: child ?? this.child,
    );
  }
}
