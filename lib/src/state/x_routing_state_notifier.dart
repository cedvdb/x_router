import 'package:flutter/cupertino.dart';
import '../route/x_activated_route.dart';
import '../state/x_routing_state.dart';

class XRoutingStateNotifier extends ValueNotifier<XRoutingState> {
  final int maxHistorySize;

  XRoutingStateNotifier({this.maxHistorySize = 10})
      : super(XRoutingState.initial());

  startNavigation(String target) {
    value = value.copyWith(status: XStatus.redirection_start, target: target);
  }

  redirect(String redirection) {
    value = value.copyWith(
        status: XStatus.resolving_start, redirection: redirection);
  }

  resolve(String resolved) {
    value = value.copyWith(
      status: XStatus.build_start,
      resolved: resolved,
    );
  }

  build(XActivatedRoute route) {
    value = value.copyWith(
      status: XStatus.navigation_end,
      // on init current could be null
      history: value.current != null ? [value.current, ...value.history] : [],
      current: route,
    );
  }

  display() {
    value = value.copyWith(
      status: XStatus.navigation_end,
    );
  }
}
