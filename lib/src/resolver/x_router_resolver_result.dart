import 'package:x_router/src/route/x_route.dart';

class XRouterResolveResult {
  final String origin;
  final String target;

  const XRouterResolveResult({
    required this.origin,
    required this.target,
  });
}

class XRouterResolveLoading extends XRouterResolveResult {
  final XPageBuilder builder;
  const XRouterResolveLoading({
    required this.builder,
    required String origin,
    required String target,
  }) : super(origin: origin, target: target);
}
