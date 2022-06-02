import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/src/router/base_router.dart';
import 'package:x_router/x_router.dart';

import 'x_child_router.dart';

/// holds child routers to access their delegate easily
/// if a route has children routes then it is a child router
class XChildRouterStore {
  final Map<String, BaseRouter> _childRouters;

  XChildRouterStore._(this._childRouters);

  factory XChildRouterStore.fromRoutes(BaseRouter parent, List<XRoute> routes) {
    final childRouters = <String, BaseRouter>{};
    _computeChildRoutersMap(parent, routes, childRouters);
    return XChildRouterStore._(childRouters);
  }

  static _computeChildRoutersMap(
    BaseRouter router,
    List<XRoute> routes,
    Map<String, BaseRouter> childRoutersMap,
  ) {
    for (final route in routes) {
      final hasChildren = route.children.isNotEmpty;
      if (hasChildren) {
        final childRouter = XChildRouter(
          parent: router,
          routes: route.children,
        );
        childRoutersMap[route.path] = childRouter;
        _computeChildRoutersMap(childRouter, route.children, childRoutersMap);
      }
    }
  }

  BaseRouter findChild(String routePath) {
    final childRouter = _childRouters[routePath];
    if (childRouter == null) {
      throw XRouterException(
          description: 'The route $routePath does not contain a child router');
    }
    return childRouter;
  }
}
