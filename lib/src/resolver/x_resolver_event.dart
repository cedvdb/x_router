import 'package:x_router/src/state/x_router_events.dart';

import '../../x_router.dart';

class ResolvingStart extends XRouterEvent {
  ResolvingStart({required String target}) : super(target);
}

class ResolvingEnd extends XRouterEvent {
  ResolvingEnd({required String target}) : super(target);
}

class ResolverResolveStart extends XRouterEvent {
  final XResolver resolver;

  ResolverResolveStart({
    required this.resolver,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveStart(target: $target, state: ${resolver.state})';
}

class ResolverResolveEnd extends XRouterEvent {
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
