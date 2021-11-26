import 'package:x_router/x_router.dart';

class XChildRoutes {
  final List<XRoute> routes;
  final List<XResolver> resolvers;

  XChildRoutes({
    required this.routes,
    required this.resolvers,
  });

  /// finds resolvers with the resolvers
  /// from the nested routes included
  List<XResolver> findAllResolvers() {
    final allResolvers = [...resolvers];
    for (final route in routes) {
      final children = route.children;
      if (children != null) {
        allResolvers.addAll(children.findAllResolvers());
      }
    }
    return allResolvers;
  }
}
