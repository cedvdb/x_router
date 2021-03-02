import 'package:flutter/cupertino.dart';
import '../route/x_activated_route.dart';
import '../state/x_routing_state.dart';

///
class XRoutingStateNotifier extends ValueNotifier<XRoutingState> {
  // maybe using a
  final int maxHistorySize;

  XRoutingStateNotifier({
    this.maxHistorySize = 10,
    XRoutingState initialState,
  }) : super(initialState ?? XRoutingState.initial());

  startNavigation(String target) {
    value = value.copyWith(
      status: XStatus.navigation_start,
      target: target,
      resolved: '',
    );
  }

  endNavigation() {
    value = value.copyWith(
      status: XStatus.navigation_end,
    );
  }

  startResolving() {
    value = value.copyWith(
      status: XStatus.resolving_start,
    );
  }

  endResolving(String resolved) {
    value = value.copyWith(
      status: XStatus.resolving_end,
      resolved: resolved,
    );
  }

  startBuild() {
    value = value.copyWith(
      status: XStatus.build_start,
    );
  }

  endBuild(XActivatedRoute route) {
    final history =
        value.current != null ? [value.current, ...value.history] : [];
    value = value.copyWith(
      status: XStatus.build_end,
      // on init current could be null
      history: history,
      current: route,
    );
  }
}
