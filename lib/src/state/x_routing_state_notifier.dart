import 'package:flutter/cupertino.dart';
import '../route/x_activated_route.dart';
import '../state/x_routing_state.dart';

class XRoutingStateNotifier extends ValueNotifier<XRoutingState> {
  final int maxHistorySize;

  /// the current state
  XRoutingState get state => value;
  set state(XRoutingState state) => value = state;

  XRoutingStateNotifier({this.maxHistorySize = 10})
      : super(XRoutingState.initial());

  startNavigation(String target) {
    state = state.copyWith(status: XStatus.resolving_start, target: target);
  }

  redirect(String redirection) {
    state =
        state.copyWith(status: XStatus.build_start, redirection: redirection);
  }

  resolve(String resolved) {
    state = state.copyWith(
      status: XStatus.redirection_start,
      resolved: resolved,
    );
  }

  build(XActivatedRoute route) {
    state = state.copyWith(
      status: XStatus.navigation_end,
      // on init current could be null
      history: state.current != null ? [state.current, ...state.history] : [],
      current: route,
    );
  }

  display() {
    state = state.copyWith(
      status: XStatus.navigation_end,
    );
  }
}
