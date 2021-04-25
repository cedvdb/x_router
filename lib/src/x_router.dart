import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_state.dart';

class XRouter {
  static final XRouterState _state = XRouterState();
  static final XRouterResolver _resolver = XRouterResolver();
  // responsible of resolving a string path to (maybe) another
  final XRouteInformationParser parser = XRouteInformationParser();
  late final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
    isRoot: _isRoot,
    onDispose: dispose,
  );
  final List<XRoute> routes;
  late final XActivatedRouteBuilder _activatedRouteBuilder =
      XActivatedRouteBuilder(routes: routes);
  // whether this router is the root resolver and not a child / nested
  final bool _isRoot;
  Function()? _userListener;

  XRouter._({
    required this.routes,
    List<XResolver> resolvers = const [],
    required bool isRoot,
  }) : _isRoot = isRoot {
    // when the resolver has modified the states this runs
    _resolver.addResolvers(resolvers);
    _resolver.addRouteResolvers(routes);
  }

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
  }) : this._(
          isRoot: true,
          routes: routes,
          resolvers: resolvers,
        );

  XRouter.child({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
  }) : this._(
          isRoot: false,
          routes: routes,
          resolvers: resolvers,
        );

  XRouter addChildren(List<XRouter> children) {
    // this is just to force instanciation of the XRouter.child
    // without it the child router could be in a widget and only instanciated
    // when accessing said widget. If there were resolvers present then they
    // would not be active until we reach the widget and a route could be
    // accessed which the user intended to have a resolver on
    return this;
  }

  static goTo(String target, {Map<String, String>? params}) {
    if (params != null) {
      target = XRouteParser(target).reverse(params);
    }
    // relative to current route
    target = _getRelativeUrl(target);
    _routerStateNotifier.startResolving(target);
  }

  /// gets the url relative to the current route if the url starts with ./
  static String _getRelativeUrl(String target) {
    // relative to current route
    if (target.startsWith('./') && _state.currentUrl != null) {
      var resolvedParts = _state.currentUrl!.split('/');
      resolvedParts.removeLast();
      target = resolvedParts.join('/') + target.substring(1);
    }
    return target;
  }

  dispose() {
    if (_userListener != null) {
      _routerStateNotifier.removeListener(_userListener!);
    }
  }

  _onRouterStateChanges() {
    final state = _routerStateNotifier.value;
    final status = state.status;

    if (status == XStatus.resolved) {
      final activatedRoute = _activatedRouteBuilder.build(state.resolved);
      delegate.initBuild(activatedRoute);
    }
  }

  _addUserListener(Function(XRouterState)? onRouterStateChanges) {
    if (onRouterStateChanges != null) {
      _userListener = () => onRouterStateChanges(_routerStateNotifier.value);
      _routerStateNotifier.addListener(_userListener!);
    }
  }
}
