import '../../x_router.dart';

/// Holds information about the currently displayed route
class XActivatedRoute {
  /// the path of the route. eg: `/team/123/route/44`
  final String path;

  /// the route pattern matched onto. eg: `Route(path: '/team/:id')`
  final XRoute route;

  /// the part of the path that is matching. eg: `/team/123`
  final String effectivePath;

  /// parameters found in the route
  final Map<String, String> parameters;

  /// the parents matching routes, the upstack
  final List<XActivatedRoute> upstack;

  XActivatedRoute({
    required this.path,
    required this.route,
    required this.effectivePath,
    this.parameters = const {},
    this.upstack = const [],
  });

  @override
  String toString() {
    return 'XActivatedRoute(path: $path, route: ${route.path}, effectivePath: $effectivePath, parameters: $parameters, upstack.length: ${upstack.length})';
  }
}
