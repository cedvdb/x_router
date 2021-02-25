import 'package:flutter/widgets.dart';

import '../../x_router.dart';

/// represent the currently displayed route
class XActivatedRoute {
  /// the path of the route. eg: `/team/123/route/44`
  final String path;

  /// the route matching onto. eg: `Route(path: '/team/:id')`
  final XRoute matcherRoute;

  /// the part of the path that is matching. eg: `/team/123`
  final String matchingPath;

  /// parameters found in the route
  final Map<String, String> parameters;

  /// the parents matching routes, the upstack
  final List<XActivatedRoute> upstack;

  XActivatedRoute({
    @required this.path,
    @required this.matcherRoute,
    @required this.matchingPath,
    this.parameters = const {},
    this.upstack = const [],
  });

  @override
  String toString() {
    return 'XActivatedRoute(path: $path, matcherRoutePath: ${matcherRoute.path}, parameters: $parameters, parents.length: ${upstack.length})';
  }
}
