import 'package:x_router/x_router.dart';

class XChildRouterConfig {
  final List<XRoute> routes;
  final List<XResolver> resolvers;

  XChildRouterConfig({
    this.resolvers = const [],
    required this.routes,
  });

  /// finds resolvers with the resolvers
  /// from the nested routes included
  List<XResolver> findAllResolvers() {
    final allResolvers = [...resolvers];
    for (final route in routes) {
      final children = route.childRouterConfig;
      if (children != null) {
        allResolvers.addAll(children.findAllResolvers());
      }
    }
    return allResolvers;
  }
}
