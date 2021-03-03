import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouterResolver {
  final List<XRouteResolver> resolvers;
  final List<XRoute> routes;
  final XRouterStateNotifier routerStateNotifier;

  XRouterResolver({
    @required this.resolvers,
    @required this.routes,
    @required this.routerStateNotifier,
  }) {
    // when the state of routing change to a resolving start, we resolve
    routerStateNotifier.addListener(_onRouterStateChanges);
    // when the state of any resolver changes we resolve the current route
    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        (resolver as ChangeNotifier).addListener(_onResolversStateChanged);
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

  _onRouterStateChanges() {
    final routingState = routerStateNotifier.value;
    if (routingState.status != XStatus.resolving) {
      return;
    }
    final resolved = resolve(routingState.target);
    routerStateNotifier.endResolving(resolved);
  }

  _onResolversStateChanged() {
    // when a resolver notify a change, the current resolved path is reresolved
    routerStateNotifier.startResolving(routerStateNotifier.value.resolved);
  }
}
