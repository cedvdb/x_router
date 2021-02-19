import 'package:flutter/cupertino.dart';
import 'package:x_router/src/state/x_activated_route.dart';
import 'package:x_router/src/state/x_activated_route_state.dart';

class XActivatedRouteNotifier extends ValueNotifier<XActivatedRouteState> {
  XActivatedRouteNotifier() : super(XActivatedRouteState.initial());

  startNavigation(String target) {
    value = value.copyWith(status: XStatus.resolving_start, target: target);
  }

  resolve(String resolved) {
    value = value.copyWith(
      status: XStatus.build_start,
      resolved: resolved,
    );
  }

  build(XActivatedRoute route) {
    value = value.copyWith(
      status: XStatus.display_start,
      // on init current could be null
      history: value.current != null ? [value.current, ...value.history] : [],
      current: route,
    );
  }

  display() {
    value = value.copyWith(
      status: XStatus.displayed,
    );
  }
}
