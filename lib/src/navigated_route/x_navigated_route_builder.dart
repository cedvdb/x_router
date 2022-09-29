import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/route/x_default_routes.dart';

import '../route/x_route.dart';

/// builds an NavigatedRoute when provided a `path`.
class XNavigatedRouteBuilder {
  final List<XRoute> _routes;

  XNavigatedRouteBuilder({
    required List<XRoute> routes,
  }) : _routes = routes;

  /// builds the page stack with the url
  ///
  /// That is if we access /products/:id, the page stack will consists of
  /// `[ProductDetailsPage, ProductsPage]`
  XNavigatedRoute build(String target) {
    var matchings = _getOrderedPartiallyMatchingRoutes(target);
    final isFound = matchings.isNotEmpty;

    if (!isFound) {
      matchings = [XNotFoundRoute(target)];
    }

    var route = matchings.removeAt(0);

    // path that also match path from active routes of child router
    final poppableStack = matchings
        .map(
          (parentRoute) => _toNavigatedRoute(
            target,
            parentRoute,
          ),
        )
        .toList();

    final activatedRoute = _toNavigatedRoute(
      target,
      route,
      poppableStack,
    );
    return activatedRoute;
  }

  XNavigatedRoute _toNavigatedRoute(
    String path,
    XRoute route, [
    List<XNavigatedRoute> poppableStack = const [],
  ]) {
    final parsed = route.parse(path);
    return XNavigatedRoute(
      requestedPath: path,
      route: route,
      matchingPath: parsed.matchingPath,
      pathParams: parsed.pathParameters,
      queryParams: parsed.queryParameters,
      poppableStack: poppableStack,
    );
  }

  List<XRoute> _getOrderedPartiallyMatchingRoutes(String path) {
    final matching = _routes.where((route) => route.match(path)).toList()
      // ordered by length so childs are after
      ..sort((a, b) => a.path.length.compareTo(b.path.length));
    // when there is no builder we don't keep going
    return matching
        .toList()
        // reverse so childs are in front
        .reversed
        .toList();
  }
}
