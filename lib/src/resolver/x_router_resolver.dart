import 'dart:async';

import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

class XRouterResolver extends XResolver {
  final List<XResolver> resolvers = [];
  final List<XRoute> routes = [];
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
    final addedRoutes = routes
        // we are only interested in routes that have resolvers
        .where((route) => route.resolvers.isNotEmpty)
        .toList()
          // sorting the routes by path length so children are after parents.
          ..sort((a, b) => a.path.length.compareTo(b.path.length));
    routesWithResolvers.addAll(addedRoutes);
  }

  Future<String> resolve(String target) async {
    var resolved = target;
    for (final resolver in resolvers) {
      resolved = await _useResolver(resolver, resolved);
    }
    resolved = await _useRouteResolvers(resolved);
    return resolved;
  }

  Future<String> _useResolver(XResolver resolver, String target) async {
    routerState
        .addEvent(ResolverResolveStart(resolver: resolver, target: target));

    final resolved = await resolver.resolve(target);
    routerState.addEvent(ResolverResolveEnd(
        resolver: resolver, target: target, resolved: resolved));
    return resolved;
  }

  /// use the route specific resolvers
  ///
  /// [calls] since this can easily lead to infinite loop by user error
  /// the calls attribute is to keep track of the number of times this fn
  /// was called recursively
  Future<String> _useRouteResolvers(String target, {int calls = 0}) async {
    final targetRoutes = routes.where((r) => r.match(target));

    if (calls > 5) {
      throw 'XRouter error: infinite resolver loop detected. '
          'This is likely because you have resolvers doing ping pong with each others, '
          'where resolver A is resolving to a route with resolver B and '
          'resolver B is resolving to a route with resolver A';
    }
    var resolved = target;
    for (var route in targetRoutes) {
      for (var resolver in route.resolvers) {
        resolved = await _useResolver(resolver, target);
        // if the route doesn't match anymore then we have to restart
        // the process for a new route
        if (!route.match(resolved)) {
          resolved = await _useRouteResolvers(resolved, calls: calls + 1);
          break;
        }
      }
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
