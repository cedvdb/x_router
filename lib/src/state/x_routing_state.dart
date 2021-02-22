import 'package:flutter/material.dart';

import '../route/x_activated_route.dart';

enum XStatus {
  initializing,
  redirection_start,
  resolving_start,
  build_start,
  display_start,
  navigation_end,
}

class XRoutingState {
  final XStatus status;
  final String redirection;
  final String resolved;
  final String target;
  final XActivatedRoute current;
  final List<XActivatedRoute> history;

  XRoutingState._({
    this.status,
    this.redirection,
    this.resolved,
    this.target,
    this.current,
    this.history,
  });

  XRoutingState.initial()
      : this._(status: XStatus.initializing, history: const []);

  XRoutingState copyWith({
    @required XStatus status,
    String resolved,
    String redirection,
    String target,
    XActivatedRoute current,
    List<XActivatedRoute> history,
  }) {
    return XRoutingState._(
      status: status ?? this.status,
      resolved: resolved ?? this.resolved,
      redirection: redirection ?? this.redirection,
      target: target ?? this.target,
      current: current ?? this.current,
      history: history ?? this.history,
    );
  }

  @override
  String toString() {
    return 'XRoutingState(status: $status, redirection: $redirection, resolved: $resolved, target: $target, current: $current, history: $history)';
  }
}
