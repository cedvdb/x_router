import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouterResolver {
  final List<XResolver> resolvers = [];
  final XRouterStateNotifier stateNotifier;

  XRouterResolver({
    required this.stateNotifier,
    List<XResolver>? resolvers,
    List<XRoute>? routes,
  }) {
    stateNotifier.addListener(_onRouterStateChanges);
    addResolvers(resolvers ?? []);
    addRouteResolvers(routes ?? []);
  }

  addResolvers(List<XResolver> resolvers) {
    this.resolvers.addAll(resolvers);
    _listenResolversStateChanges(resolvers);
  }

  addRouteResolvers(List<XRoute> routes) {
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
    stateNotifier.removeListener(_onRouterStateChanges);
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).removeListener(_onResolverStateChanges);
      }
    });
  }

  void _onRouterStateChanges() async {
    final state = stateNotifier.value;
    final status = state.status;

    if (status == XStatus.resolving) {
      final resolved = await resolve(state.target);
      stateNotifier.endResolving(resolved);
    }
  }

  void _onResolverStateChanges() {
    stateNotifier.startResolving(stateNotifier.value.resolved);
  }

  void _listenResolversStateChanges(List<XResolver> resolvers) {
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).removeListener(_onResolverStateChanges);
      }
    });
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        // when changes happen we trigger resolving with the currently
        // resolved path
        (resolver as ChangeNotifier).addListener(_onResolverStateChanges);
      }
    });
  }
}
