import 'package:x_router/src/child_router/x_child_router.dart';
import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/src/router/base_router.dart';
import 'package:x_router/x_router.dart';

/// holds child routers to access their delegate easily
/// if a route has children routes then it is a child router
class XChildRouterStore {
  final Map<XRoute, XChildRouter> _childRouters;

  XChildRouterStore._(this._childRouters);

  factory XChildRouterStore.fromRootRoutes(
      XRouter parent, List<XRoute> routes) {
    final childRouters = <XRoute, XChildRouter>{};
    _computeChildRoutersMap(parent, routes, childRouters);
    return XChildRouterStore._(childRouters);
  }

  static _computeChildRoutersMap(
    BaseRouter router,
    List<XRoute> routes,
    Map<XRoute, BaseRouter> childRoutersMap,
  ) {
    for (final route in routes) {
      final hasChildren = route.children.isNotEmpty;
      if (hasChildren) {
        final childRouter = XChildRouter(
          parent: router,
          routes: route.children,
        );
        childRoutersMap[route] = childRouter;
        _computeChildRoutersMap(childRouter, route.children, childRoutersMap);
      }
    }
  }

  XChildRouter findChild(XRoute route) {
    final childRouter = _childRouters[route];
    if (childRouter == null) {
      throw XRouterException(
          description:
              'The route ${route.path} does not contain a child router');
    }
    return childRouter;
  }
}
