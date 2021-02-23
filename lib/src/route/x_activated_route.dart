import '../../x_router.dart';

/// represent the currently displayed route
class XActivatedRoute {
  /// the path of the route. eg: `/route/123`
  final String path;

  /// the route matching onto. eg: `Route(path: '/route/:id')`
  final XRoute matcherRoute;

  /// parameters found in the route
  final Map<String, String> parameters;

  /// the parents matching routes
  final List<XActivatedRoute> parents;

  XActivatedRoute({
    this.path,
    this.matcherRoute,
    this.parameters = const {},
    this.parents = const [],
  });

  @override
  String toString() {
    return 'XActivatedRoute(path: $path, matcherRoutePath: ${matcherRoute.path}, parameters: $parameters, parents.length: ${parents.length})';
  }
}
