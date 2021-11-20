import 'dart:async';

import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';

import 'x_resolver_event.dart';

class XRouterResolver extends XResolver {
  List<XResolver> _globalResolvers = [];
  final List<XRoute> _routes = [];
  final void Function() _onStateChanged;
  final XRouterState _routerState = XRouterState.instance;
  final List<StreamSubscription> _routeResolversSubscriptions = [];

  XRouterResolver({
    required void Function() onStateChanged,
  }) : _onStateChanged = onStateChanged;

  void addResolvers(List<XResolver> resolvers) {
    _globalResolvers.addAll(resolvers);
    _listenResolversStateChanges(resolvers);
  }

  void addRoutes(List<XRoute> addedRoutes) {
    addedRoutes = addedRoutes
        // we are only interested in routes that have resolvers
        .where((route) => route.resolvers.isNotEmpty)
        .toList()
      // sorting the routes by path length so children are after parents.
      ..sort((a, b) => a.path.length.compareTo(b.path.length));
    _routes.addAll(addedRoutes);
  }

  Future<String> resolve(String target) async {
    var resolved = target;
    for (final resolver in _globalResolvers) {
      resolved = await _useResolver(resolver, resolved);
    }
    resolved = await _useRouteResolvers(resolved);
    _listenToRouteResolvers(target);
    return resolved;
  }

  Future<String> _useResolver(XResolver resolver, String target) async {
    _routerState
        .addEvent(ResolverResolveStart(resolver: resolver, target: target));

    final resolved = await resolver.resolve(target);
    _routerState.addEvent(ResolverResolveEnd(
        resolver: resolver, target: target, resolved: resolved));
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

  /// listen to resolvers that are on a specific path
  void _listenToRouteResolvers(String target) {
    // cancel previous subscriptions since the path might have changed
    final targetRoutes = _routes.where((route) => route.match(target));
    _routeResolversSubscriptions.forEach((sub) => sub.cancel());
    for (var route in targetRoutes) {
      _routeResolversSubscriptions
          .addAll(_listenResolversStateChanges(route.resolvers));
    }
  }
}
