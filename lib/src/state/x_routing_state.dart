import 'package:flutter/material.dart';
import 'package:x_router/src/route/x_special_routes.dart';

import '../route/x_activated_route.dart';

enum XStatus {
  initializing,
  navigation_start,
  resolving_start,
  resolving_end,
  build_start,
  build_end,
  navigation_end,
}

class XRoutingState {
  final XStatus status;
  final String target;
  final String resolved;
  final XActivatedRoute current;
  final List<XActivatedRoute> history;

  XRoutingState({
    this.status,
    this.resolved,
    this.target,
    this.current,
    this.history,
  });

  XRoutingState.initial()
      : this(
          status: XStatus.initializing,
          // even though we don't have yet an activated route
          // the build method of the delegate wants a widget to build
          // so to satifsy that we provide a matcher route it is going to use to build
          current: XActivatedRoute(
            matchingRoute: XSpecialRoutes.initializationRoute,
            effectivePath: null,
            path: null,
          ),
          history: const [],
        );

  XRoutingState copyWith({
    @required XStatus status,
    String resolved,
    String redirection,
    String target,
    XActivatedRoute current,
    List<XActivatedRoute> history,
  }) {
    return XRoutingState(
      status: status ?? this.status,
      resolved: resolved ?? this.resolved,
      target: target ?? this.target,
      current: current ?? this.current,
      history: history ?? this.history,
    );
  }

  @override
  String toString() {
    return 'XRoutingState(status: $status, target: $target, resolved: $resolved, current: $current, history.length: ${history.length})';
  }
}
