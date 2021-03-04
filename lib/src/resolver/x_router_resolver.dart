import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRouterResolver {
  final List<XRouteResolver> resolvers;
  final List<XRoute> routes;

  XRouterResolver({
    @required this.resolvers,
    @required this.routes,
  });

  String resolve(String target) {
    var resolved = target;
    for (var resolver in resolvers) {
      resolved = resolver.resolve(resolved, routes);
    }
    return resolved;
  }
}
