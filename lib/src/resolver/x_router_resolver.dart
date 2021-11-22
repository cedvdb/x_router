import 'dart:async';

import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';

import 'x_resolver_event.dart';

class XRouterResolver {
  List<XResolver> _resolvers = [];
  final void Function() _onStateChanged;
  final XRouterState _routerState = XRouterState.instance;
  List<StreamSubscription> _resolversSubscriptions = [];

  XRouterResolver({
    required void Function() onStateChanged,
    required List<XRoute> routes,
    required List<XResolver> resolvers,
  }) : _onStateChanged = onStateChanged {
    _resolvers.addAll(resolvers);
    _resolvers.addAll(_getRoutesResolvers(routes));
    _resolversSubscriptions = _listenResolversStateChanges(resolvers);
  }

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
  ///
  /// [calls] since this can easily lead to infinite loop by user error
  /// the calls attribute is to keep track of the number of times this fn
  /// was called recursively
  XRouterResolveResult resolve(
    String path, {
    bool isRedirect = false,
    int calls = 0,
  }) {
    _checkInfiniteLoop(calls);
    var next = path;

    for (final resolver in _resolvers) {
      final resolved = _useResolver(resolver, next);

      if (resolved is End) {
        return XRouterResolveResult(
          origin: path,
          target: next,
        );
      }

      if (resolved is Loading) {
        // if it is loading we need to wait for an effective result
        // so this is the end, but we override the builder
        // so the client can display a loading screen
        return XRouterResolveResult(
          builder: (_, __) => resolved.loadingScreen,
          origin: path,
          target: next,
        );
      }

      // if it is a redirect then we start the resolving process over
      if (resolved is Redirect) {
        return resolve(
          resolved.target,
          isRedirect: true,
          calls: calls + 1,
        );
      }
    }
    // if we reach here we have resolved the final route
    return XRouterResolveResult(
      origin: path,
      target: next,
    );
  }

  /// resolve path against a specific resolver
  XResolverAction _useResolver(XResolver resolver, String path) {
    _routerState
        .addEvent(ResolverResolveStart(resolver: resolver, target: path));

    final resolved = resolver.resolve(path);
    _routerState.addEvent(ResolverResolveEnd(
        resolver: resolver, target: path, resolved: resolved));
    return resolved;
  }

  /// checks if the number of redirects passes over a threshold
  void _checkInfiniteLoop(int redirectAmount) {
    // 10 is arbitrary here, it's the max number of redirects before
    // we decide it's an infinite loop
    if (redirectAmount > 10) {
      throw 'XRouter error: infinite resolver loop detected. '
          'This is likely because you have resolvers doing ping pong with each others, '
          'where resolver A is resolving to a route with resolver B and '
          'resolver B is resolving to a route with resolver A';
    }
  }

  List<StreamSubscription> _listenResolversStateChanges(
      List<XResolver> resolvers) {
    return resolvers
        .map((resolver) => resolver.state$.listen((_) => _onStateChanged()))
        .toList();
  }

  dispose() {
    _resolversSubscriptions.forEach((sub) => sub.cancel());
  }
}
