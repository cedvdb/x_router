import 'package:flutter/cupertino.dart';
import 'x_router_state.dart';

///
class XRouterStateNotifier extends ValueNotifier<XRouterState> {
  XRouterStateNotifier() : super(XRouterState.initial());

  startResolving(String target) {
    value = value.copyWith(
      status: XStatus.resolving,
      target: target,
    );
  }

  endResolving(String resolved) {
    value = value.copyWith(
      status: XStatus.resolved,
      resolved: resolved,
    );
  }
}
