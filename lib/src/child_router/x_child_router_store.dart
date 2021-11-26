import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/x_router.dart';

/// holds child routers to access their delegate easily
class XChildRouterStore {
  final Map<String, XChildRouter> _childRouters = {};
  final XEventEmitter _emitter;

  XChildRouterStore({
    required XEventEmitter emitter,
    required List<XRoute> routes,
  }) : _emitter = emitter {
    _storeChildRouters(routes);
  }

  _storeChildRouters(List<XRoute> routes) {
    for (final route in routes) {
      final children = route.children;
      if (children != null) {
        _childRouters[route.path] = XChildRouter(
          basePath: route.path,
          eventEmitter: _emitter,
          routes: routes,
        );
        _storeChildRouters(children.routes);
      }
    }
  }

  XRouterDelegate findDelegate(String path) {
    final childRouter = _childRouters[path];
    if (childRouter == null) {
      throw 'The path $path has not been configured as a child router';
    }
    return childRouter.delegate;
  }
}
