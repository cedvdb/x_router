import 'x_route.dart';

/// builds an Activated route when provided a `path`.
class XActivatedRouteBuilder {
  final List<XRoute> routes;

  XActivatedRouteBuilder({
    this.routes,
  });

  build(String path) {}

  List<XRoute> _getOrderedMatchingRoutes(String path) {
    routes.map((route) => route.match(path));
  }
}
