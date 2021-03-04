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
    required this.status,
    required this.resolved,
    required this.target,
  });

  XRouterState.initial()
      : this(
          status: XStatus.initializing,
          target: '',
          resolved: '',
        );

  @override
  String toString() =>
      'XRoutingState(status: $status, target: $target, resolved: $resolved)';

  XRouterState copyWith({
    XStatus? status,
    String? target,
    String? resolved,
  }) {
    return XRouterState(
      status: status ?? this.status,
      target: target ?? this.target,
      resolved: resolved ?? this.resolved,
    );
  }
}
