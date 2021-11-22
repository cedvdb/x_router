import 'package:x_router/src/route/x_route.dart';

class XRouterResolveResult {
  final String origin;
  final String target;
  final XPageBuilder? builder;

  const XRouterResolveResult(
      {required this.origin, required this.target, this.builder});
}
