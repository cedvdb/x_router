/// represent the current displayed route
class XActivatedRoute {
  /// the path of the route
  final String path;

  /// the path of the route matched onto
  final String matcherRoutePath;

  /// paramters found in the route
  final Map<String, String> parameters;

  /// the parents matching routes (the upstack)
  final List<XActivatedRoute> parents;

  XActivatedRoute({
    this.path,
    this.matcherRoutePath,
    this.parameters,
    this.parents,
  });

  @override
  String toString() {
    return 'XActivatedRoute(path: $path, matcherRoutePath: $matcherRoutePath, parameters: $parameters, parents: $parents)';
  }
}
