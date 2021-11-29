import '../../x_router.dart';

class ResolverResolveStart extends ResolvingEvent {
  final XResolver resolver;

  ResolverResolveStart({
    required this.resolver,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveStart(target: $target)';

  @override
  List<Object?> get props => [resolver, target];
}

class ResolverResolveEnd extends ResolvingEvent {
  final XResolver resolver;
  final XResolverAction resolved;

  ResolverResolveEnd({
    required this.resolver,
    required this.resolved,
    required String target,
  }) : super(target);

  @override
  String toString() =>
      '    ${resolver.runtimeType} ResolveEnd(resolved: $resolved, target: $target)';

  @override
  List<Object?> get props => [resolver, resolved];
}
