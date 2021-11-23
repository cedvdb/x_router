import 'package:equatable/equatable.dart';
import 'package:x_router/src/route/x_page_builder.dart';

class XRouterResolveResult with EquatableMixin {
  final String target;
  final XPageBuilder? builderOverride;

  const XRouterResolveResult({
    required this.target,
    this.builderOverride,
  });

  @override
  List<Object?> get props => [target, builderOverride];
}
