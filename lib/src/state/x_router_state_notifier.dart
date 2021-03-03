import 'package:flutter/cupertino.dart';
import 'x_router_state.dart';

///
class XRouterStateNotifier extends ValueNotifier<XRouterState> {
  final int maxHistorySize;

  XRouterStateNotifier({
    this.maxHistorySize = 10,
  }) : super(XRouterState.initial());

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
