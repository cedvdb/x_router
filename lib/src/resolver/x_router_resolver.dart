import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';
import 'package:x_router/src/state/x_routing_state.dart';

class XRouterResolver {
  final List<XRouteResolver> resolvers;
  final List<XRoute> routes;
  final XRoutingStateNotifier routingStateNotifier;

  XRouterResolver({
    @required this.resolvers,
    @required this.routes,
    @required this.routingStateNotifier,
  }) {
    // when the state of routing change to a resolving start, we resolve
    routingStateNotifier.addListener(_onRoutingStateChanges);
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

  _onRoutingStateChanges() {
    final routingState = routingStateNotifier.value;
    if (routingState.status != XStatus.resolving_start) {
      return;
    }
    final resolved = resolve(routingState.target);
    routingStateNotifier.resolve(resolved);
  }

  _onResolversStateChanged() {
    routingStateNotifier
        .startNavigation(routingStateNotifier.value.current.path);
  }
}
