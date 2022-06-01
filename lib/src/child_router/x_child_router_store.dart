import 'package:x_router/src/child_router/x_child_router.dart';
import 'package:x_router/src/exceptions/x_router_exception.dart';
import 'package:x_router/x_router.dart';

/// holds child routers to access their delegate easily
/// if a route has children routes then it is a child router
class XChildRouterStore {
  final Map<String, XRouter> _childRouters;

  XChildRouterStore._(this._childRouters);

  factory XChildRouterStore.fromRootRoutes(List<XRoute> routes) {
    final childRouters = <XRoute, XRouter>{};
    _computeChildRoutersMap(routes, childRouters);
    return XChildRouterStore._(childRouters);
  }

  static _computeChildRoutersMap(
    List<XRoute> routes,
    Map<XRoute, XRouter> childRouters,
  ) {
    for (final route in routes) {
      final children = route.children;
      childRouters[route] = XChildRouter(
        basePath: route.path,
        routes: children,
      );
      _computeChildRoutersMap(children, childRouters);
    }
  }

  XChildRouter findChild(XRoute route) {
    final childRouter = _childRouters[route];
    if (childRouter == null) {
      throw XRouterException(
          description:
              'The path $path has not been configured as a child router');
    }
    return childRouter;
  }
}
