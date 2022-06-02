import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/route/x_default_routes.dart';
import 'package:x_router/src/route/x_page_builder.dart';

import '../route/x_route.dart';

/// builds an Activated route when provided a `path`.
class XNavigatedRouteBuilder {
  final List<XRoute> _routes;

  XNavigatedRouteBuilder({
    required List<XRoute> routes,
  }) : _routes = routes;

  /// builds the page stack with the url
  ///
  /// That is if we access /products/:id, the page stack will consists of
  /// `[ProductDetailsPage, ProductsPage]`
  XNavigatedRoute build(String target, {XPageBuilder? builderOverride}) {
    var matchings = _getOrderedPartiallyMatchingRoutes(target);
    final isFound = matchings.isNotEmpty;

    if (!isFound) {
      matchings = [XNotFoundRoute(target)];
    }

    var route = matchings.removeAt(0);

    // todo note (uncap) : The next line does not fit inside this method, as its
    // not really the point of this function, because of this line it is
    // doing two things at once. This could be refactored
    // in yet another (tiny) layer. Something to think about, left as pending.
    if (builderOverride != null) {
      route = route.copyWithBuilder(builder: builderOverride);
    }
    // path that also match path from active routes of child router
    final effectivePath = route.computeDeepestMatchingPath(target);
    final poppableStack = matchings
        .map(
          (parentRoute) => _toActivatedRoute(
            target,
            effectivePath,
            parentRoute,
          ),
        )
        .toList();

    final activatedRoute = _toActivatedRoute(
      target,
      effectivePath,
      route,
      poppableStack,
    );
    return activatedRoute;
  }

  XNavigatedRoute _toActivatedRoute(
    String path,
    String effectivePath,
    XRoute route, [
    List<XNavigatedRoute> poppableStack = const [],
  ]) {
    final parsed = route.parse(path);
    return XNavigatedRoute(
      requestedPath: path,
      effectivePath: effectivePath,
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
