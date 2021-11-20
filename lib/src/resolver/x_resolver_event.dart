import 'package:x_router/src/state/x_router_events.dart';

import '../../x_router.dart';

class ResolverResolveStart extends ResolvingEvent {
  final XResolver resolver;

  ResolverResolveStart({
    required this.resolver,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveStart(target: $target, state: ${resolver.state})';
}

class ResolverResolveEnd extends ResolvingEvent {
  final XResolver resolver;
  final String resolved;

  ResolverResolveEnd({
    required this.resolver,
    required this.resolved,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveEnd(resolved: $resolved, target: $target, state: ${resolver.state})';
}
