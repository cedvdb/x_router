import 'dart:async';

import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

class XRouterResolver extends XResolver {
  final List<XResolver> resolvers = [];
  final void Function() onStateChanged;
  final XRouterState routerState;
  final List<StreamSubscription> _resolverSubscriptions = [];

  XRouterResolver({
    required this.onStateChanged,
    required this.routerState,
  });

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
      final state = resolver.state.toString();
      final type = resolver.runtimeType.toString();
      routerState.addEvent(
        ResolverResolveStart(
          state: state,
          type: type,
          target: target,
        ),
      );
      resolved = await resolver.resolve(resolved);
      routerState.addEvent(
        ResolverResolveEnd(
          state: state,
          type: type,
          target: target,
          resolved: resolved,
        ),
      );
    }
    return resolved;
  }

  void _listenResolversStateChanges(List<XResolver> resolvers) {
    // when adding / routes we just remove every listener that were added
    // previously and readd them for all resolvers
    _resolverSubscriptions.forEach((sub) => sub.cancel());
    _resolverSubscriptions.removeWhere((_) => true);
    resolvers.forEach((resolver) {
      final sub = resolver.state$.listen((_) => onStateChanged());
      _resolverSubscriptions.add(sub);
    });
  }
}
