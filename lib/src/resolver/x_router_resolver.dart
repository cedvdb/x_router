import 'dart:async';

import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';

import 'x_resolver_event.dart';

class XRouterResolver extends XResolver {
  List<XResolver> _resolvers = [];
  final void Function() _onStateChanged;
  final XRouterState _routerState = XRouterState.instance;
  final List<StreamSubscription> _routeResolversSubscriptions = [];

  XRouterResolver({
    required void Function() onStateChanged,
    required List<XRoute> routes,
    required List<XResolver> resolvers,
  }) : _onStateChanged = onStateChanged {
    _resolvers.addAll(resolvers);
    _resolvers.addAll(_getRoutesResolvers(routes));
    _listenResolversStateChanges(resolvers);
  }

  dispose() {}

  /// gets the resolvers from the routes
  List<XResolver> _getRoutesResolvers(List<XRoute> routes) {
    routes = routes
        // we are only interested in routes that have resolvers
        .where((route) => route.resolvers.isNotEmpty)
        .toList()
      // sorting the routes by path length so children are after parents.
      ..sort((a, b) => a.path.length.compareTo(b.path.length));
    final routesResolvers = routes.fold<List<XResolver>>(
      [],
      (previousValue, route) => previousValue..addAll(route.resolvers),
    ).toList();
    return routesResolvers;
  }

  /// resolve target path against the list of resolvers
  Future<String> resolve(String path) async {
    var resolved = path;
    for (final resolver in _globalResolvers) {
      resolved = await _useResolver(resolver, resolved);
    }
    resolved = await _useRouteResolvers(resolved);
    _listenToRouteResolvers(path);
    return resolved;
  }

  /// resolve path against a specific resolver
  Future<String> _useResolver(XResolver resolver, String path) async {
    _routerState
        .addEvent(ResolverResolveStart(resolver: resolver, target: path));

    final resolved = await resolver.resolve(path);
    _routerState.addEvent(ResolverResolveEnd(
        resolver: resolver, target: path, resolved: resolved));
    return resolved;
  }

  /// use the route specific resolvers
  ///
  /// [calls] since this can easily lead to infinite loop by user error
  /// the calls attribute is to keep track of the number of times this fn
  /// was called recursively
  Future<String> _useRouteResolvers(String target, {int calls = 0}) async {
    final targetRoutes = _routes.where((r) => r.match(target));

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

  List<StreamSubscription> _listenResolversStateChanges(
      List<XResolver> resolvers) {
    return resolvers
        .map((resolver) => resolver.state$.listen((_) => _onStateChanged()))
        .toList();
  }
}
