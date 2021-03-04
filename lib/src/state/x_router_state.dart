enum XStatus {
  initializing,
  resolving,
  resolved,
}

class XRouterState {
  final XStatus status;
  final String target;
  final String resolved;

  XRouterState({
    this.status,
    this.resolved,
    this.target,
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
  }) {
    return XRouterState(
      status: status ?? this.status,
      target: target ?? this.target,
      resolved: resolved ?? this.resolved,
    );
  }
}
