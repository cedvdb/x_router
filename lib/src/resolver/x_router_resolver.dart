import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';

class XRouterResolver {
  final List<XResolver> resolvers = const [];
  final void Function() onStateChanged;

  const XRouterResolver({required this.onStateChanged});

  void addResolvers(List<XResolver> resolvers) {
    this.resolvers.addAll(resolvers);
    _listenResolversStateChanges(resolvers);
  }

  void addRouteResolvers(List<XRoute> routes) {
    List<XResolver> resolvers = [];
    // sorting the routes by path length so children are after parents.
    routes.sort((a, b) => a.path.length.compareTo(b.path.length));
    for (final route in routes) {
      final routeResolvers = route.resolvers
          .map((r) => XRouteResolver(resolver: r, route: route))
          .toList();
      resolvers.addAll(routeResolvers);
    }
    addResolvers(resolvers);
  }

  Future<String> resolve(String target) async {
    var resolved = target;
    for (final resolver in resolvers) {
      resolved = await resolver.resolve(resolved);
    }
    return resolved;
  }

  dispose() {
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).removeListener(onStateChanged);
      }
    });
  }

  void _listenResolversStateChanges(List<XResolver> resolvers) {
    // when adding / routes we just remove every listener that were added
    // previously and readd them for all resolvers
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).removeListener(onStateChanged);
      }
    });
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).addListener(onStateChanged);
      }
    });
  }
}
