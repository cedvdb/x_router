import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRouterResolver {
  final List<XRouteResolver> resolvers;
  final List<XRoute> routes;
  final Function onStateChanges;

  XRouterResolver({
    @required this.resolvers,
    @required this.routes,
    @required this.onStateChanges,
  }) {
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).addListener(onStateChanges);
      }
    });
  }

  String resolve(String target) {
    var resolved = target;
    for (var resolver in resolvers) {
      resolved = resolver.resolve(resolved, routes);
    }
    return resolved;
  }

  dispose() {
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).removeListener(onStateChanges);
      }
    });
  }
}
