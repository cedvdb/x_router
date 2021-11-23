import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_default_routes.dart';
import 'package:x_router/src/route/x_page_builder.dart';

import '../route/x_route.dart';

/// builds an Activated route when provided a `path`.
class XActivatedRouteBuilder {
  final List<XRoute> _routes;

  XActivatedRouteBuilder({
    required List<XRoute> routes,
  }) : _routes = routes;

  /// builds the page stack with the url
  ///
  /// That is if we access /products/:id, the page stack will consists of
  /// `[ProductDetailsPage, ProductsPage]`
  XActivatedRoute build(String target, {XPageBuilder? builderOverride}) {
    var matchings = _getOrderedPartiallyMatchingRoutes(target);
    final isFound = matchings.isNotEmpty;

    if (!isFound) {
      matchings = [XDefaultRoutes.notFoundRoute];
    }

    var route = matchings.removeAt(0);

    if (builderOverride != null) {
      route = route.copyWithBuilder(builder: builderOverride);
    }

    final upstack = matchings
        .map(
          (parentRoute) => _toActivatedRoute(
            target,
            parentRoute,
          ),
        )
        .toList();

    final activatedRoute = _toActivatedRoute(
      target,
      route,
      upstack,
    );
    return activatedRoute;
  }

  XActivatedRoute _toActivatedRoute(
    String path,
    XRoute route, [
    List<XActivatedRoute> upstack = const [],
  ]) {
    final parsed = route.parse(path);
    return XActivatedRoute(
      requestedPath: path,
      route: route,
      effectivePath: parsed.matchingPath,
      pathParams: parsed.pathParameters,
      queryParams: parsed.queryParameters,
      upstack: upstack,
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
