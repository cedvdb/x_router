import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';
import 'package:x_router/src/state/x_routing_state.dart';

class XRouterResolver {
  final List<XRouteResolver> resolvers;
  final XRoutingStateNotifier routingStateNotifier;

  XRouterResolver({
    @required this.resolvers,
    @required this.routingStateNotifier,
  }) {
    // when the state of routing change to a resolving start, we resolve
    routingStateNotifier.addListener(_onActivatedRouteChanges);
    // when the state of any resolver changes we resolve the current route
    resolvers
        .forEach((resolver) => resolver.addListener(_onResolversStateChanged));
  }

  String resolve(String target) {
    var resolved = target;
    for (var resolver in resolvers) {
      resolved = resolver.resolve(resolved);
    }
    return resolved;
  }

  _onActivatedRouteChanges() {
    final routingState = routingStateNotifier.state;
    if (routingState.status != XStatus.resolving_start) {
      return;
    }
    final resolved = resolve(routingState.directedTo);
    routingStateNotifier.resolve(resolved);
  }

  _onResolversStateChanged() {
    final currentRoute = routingStateNotifier.value.current.path;
    resolve(currentRoute);
  }

  dispose() {
    routingStateNotifier.removeListener(_onActivatedRouteChanges);
    resolvers.forEach(
        (resolver) => resolver.removeListener(_onResolversStateChanged));
  }
}
