import 'package:flutter/widgets.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';
import 'package:x_router/src/state/x_router_state_notifier.dart';

class XRouterResolver {
  final List<XResolver> resolvers;
  final List<XRoute> routes;
  final XRouterStateNotifier stateNotifier;

  XRouterResolver({
    required this.resolvers,
    required this.routes,
    required this.stateNotifier,
  }) {
    stateNotifier.addListener(_onRouterStateChanges);

    resolvers.forEach((resolver) {
      if (resolver is ChangeNotifier) {
        // when changes happen we trigger resolving with the currently
        // resolved path
        (resolver as ChangeNotifier).addListener(_onResolverStateChanges);
      }
    });
  }

  void _onRouterStateChanges() {
    final state = stateNotifier.value;
    final status = state.status;

    if (status == XStatus.resolving) {
      final resolved = resolve(state.target);
      stateNotifier.endResolving(resolved);
    }
  }

  void _onResolverStateChanges() {
    stateNotifier.startResolving(stateNotifier.value.resolved);
  }

  String resolve(String target) {
    var resolved = target;
    for (var resolver in resolvers) {
      resolved = resolver.resolve(resolved, routes);
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
}
