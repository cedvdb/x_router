import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';
import 'package:x_router/src/state/x_routing_state.dart';

class XRouterResolver {
  final List<RouteResolver> resolvers;
  final XRoutingStateNotifier routingStateNotifier;

  XRouterResolver({this.resolvers, this.routingStateNotifier}) {
    // when the state of routing change to a resolving start, we resolve
    routingStateNotifier.addListener(_onActivatedRouteChanges);
    // when the state of any resolver changes we resolve the current route
    resolvers
        .forEach((resolver) => resolver.addListener(_onResolversStateChanged));
  }

  Future<String> resolve(String target) async {
    var resolved = target;
    for (var resolver in resolvers) {
      resolved = await resolver.resolve(resolved);
    }
    return resolved;
  }

  _onActivatedRouteChanges() async {
    final routingState = routingStateNotifier.value;
    if (routingState.status != XStatus.resolving_start) {
      return;
    }
    final resolved = await resolve(routingState.target);
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
