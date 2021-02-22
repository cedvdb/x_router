/// represent the currently displayed route
class XActivatedRoute {
  /// the path of the route. eg: `/route/123`
  final String path;

  /// the path of the route matched onto. eg: `/route/:id`
  final String matcherRoutePath;

  /// parameters found in the route
  final Map<String, String> parameters;

  /// the parents matching routes
  final List<XActivatedRoute> parents;

  XActivatedRoute({
    this.path,
    this.matcherRoutePath,
    this.parameters,
    this.parents = const [],
  });

  @override
  String toString() {
    return 'XActivatedRoute(path: $path, matcherRoutePath: $matcherRoutePath, parameters: $parameters, upstack.length: ${parents.length})';
  }
}
