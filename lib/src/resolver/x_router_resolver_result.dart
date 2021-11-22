import 'package:equatable/equatable.dart';
import 'package:x_router/src/route/x_page_builder.dart';

class XRouterResolveResult with EquatableMixin {
  final String origin;
  final String target;
  final XPageBuilder? builder;

  const XRouterResolveResult({
    required this.origin,
    required this.target,
    this.builder,
  });

  @override
  List<Object?> get props => [origin, target, builder];
}
