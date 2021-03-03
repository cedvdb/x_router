import 'package:flutter/material.dart';

import 'package:x_router/src/activated_route/x_activated_route.dart';

enum XStatus {
  initializing,
  resolving,
  resolved,
}

class XRouterState {
  final XStatus status;
  final String target;
  final String resolved;
  final List<String> history;
  final Map<String, XActivatedRoute> activatedRoutes;

  XRouterState({
    this.status,
    this.resolved,
    this.target,
    this.history = const [],
    this.activatedRoutes = const {},
  });

  XRouterState.initial()
      : this(
          status: XStatus.initializing,
          target: null,
          resolved: null,
        );

  @override
  String toString() =>
      'XRoutingState(status: $status, target: $target, resolved: $resolved)';

  XRouterState copyWith({
    XStatus status,
    String target,
    String resolved,
    List<String> history,
    Map<String, XActivatedRoute> activatedRoutes,
  }) {
    return XRouterState(
      status: status ?? this.status,
      target: target ?? this.target,
      resolved: resolved ?? this.resolved,
      history: history ?? this.history,
      activatedRoutes: activatedRoutes ?? this.activatedRoutes,
    );
  }
}
