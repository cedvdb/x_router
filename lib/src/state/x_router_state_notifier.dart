import 'package:flutter/cupertino.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';
import 'x_router_state.dart';

///
class XRouterStateNotifier extends ValueNotifier<XRouterState> {
  final int maxHistorySize;

  XRouterStateNotifier({
    this.maxHistorySize = 10,
  }) : super(XRouterState.initial());

  addRouter(String name) {
    value.activatedRoutes[name] = null;
    // trigger notifier
    value = value;
  }

  removeRouter(String name) {
    value.activatedRoutes.remove(name);
    value = value;
  }

  startResolving(String target) {
    value = value.copyWith(
      status: XStatus.resolving,
      target: target,
    );
  }

  endResolving(String resolved) {
    final history =
        [value.resolved, ...value.history].toList().getRange(0, maxHistorySize);
    value = value.copyWith(
      status: XStatus.resolved,
      resolved: resolved,
      history: history,
    );
  }
}
