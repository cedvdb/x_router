import 'package:flutter/material.dart';

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

  XRouterState({
    this.status,
    this.resolved,
    this.target,
    this.history = const [],
  });

  XRouterState.initial()
      : this(
          status: XStatus.initializing,
          target: null,
          resolved: null,
        );

  XRouterState copyWith({
    @required XStatus status,
    String resolved,
    String target,
    List<String> history,
  }) {
    return XRouterState(
      status: status ?? this.status,
      resolved: resolved ?? this.resolved,
      target: target ?? this.target,
      history: history ?? this.history,
    );
  }

  @override
  String toString() =>
      'XRoutingState(status: $status, target: $target, resolved: $resolved)';
}
