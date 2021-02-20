import 'package:flutter/material.dart';
import '../route/x_activated_route.dart';

enum XStatus {
  initializing,
  resolving_start,
  build_start,
  display_start,
  navigation_end,
  failure
}

class XRoutingState {
  final XStatus status;
  final String resolved;
  final String target;
  final XActivatedRoute current;
  final List<XActivatedRoute> history;

  XRoutingState._({
    this.status,
    this.resolved,
    this.target,
    this.current,
    this.history,
  });

  XRoutingState.initial()
      : this._(status: XStatus.initializing, history: const []);

  @override
  String toString() {
    return 'XActivatedRouteState(status: $status, resolved: $resolved, target: $target, current: $current, history: $history)';
  }

  XRoutingState copyWith({
    @required XStatus status,
    String resolved,
    String target,
    XActivatedRoute current,
    List<XActivatedRoute> history,
  }) {
    return XRoutingState._(
      status: status ?? this.status,
      resolved: resolved ?? this.resolved,
      target: target ?? this.target,
      current: current ?? this.current,
      history: history ?? this.history,
    );
  }
}
