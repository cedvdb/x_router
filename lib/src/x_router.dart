import 'dart:async';

import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

/// Handles navigation
///
/// To navigate simply call XRouter.goTo(routes, params) static method.
class XRouter {
  /// the current state of the navigation
  static final XRouterState _state = XRouterState.instance;

  /// the resolver responsible of resolving a route path
  static final XRouterResolver _resolver = XRouterResolver(
    onStateChanged: () => goTo(_state.currentUrl),
  );

  /// builds the route up stack
  late final XActivatedRouteBuilder _activatedRouteBuilder =
      XActivatedRouteBuilder(
    routes: _routes,
    isRoot: _isRoot,
  );

  /// all the routes for this router
  final List<XRoute> _routes;

  /// whether this router is the root resolver or a child / nested one
  final bool _isRoot;

  // For flutter Router 2: responsible of resolving a string path to (maybe) another
  final XRouteInformationParser informationParser = XRouteInformationParser();
  late final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
    isRoot: _isRoot,
    onDispose: () {},
    onPop: pop,
  );

  static void goTo(String target, {Map<String, String>? params}) async {
    _state.addEvent(NavigationStart(target: target, params: params));
  }

  static void back() {
    throw 'unimplemented';
  }

  static void pop() {
    if (_state.activatedRoute != null &&
        _state.activatedRoute!.upstack.length >= 1) {
      goTo(_state.activatedRoute!.upstack.last.effectivePath);
    }
  }

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
    Function(XRouterEvent)? onEvent,
  })  : _isRoot = true,
        _routes = routes {
    _resolver.addResolvers(resolvers);
    _resolver.addRoutes(routes);

    _state.events$.listen((event) {
      onEvent?.call(event);
      _onNavigationEvent(event);
    });
  }

  XRouter.child({
    required String basePath,
    required List<XRoute> routes,
  })  : _routes = routes,
        _isRoot = false {
    _state.events$
        .where((event) => event is BuildStart)
        .where((event) =>
            XRoutePattern(basePath).match(event.target, matchChildren: true))
        .listen((event) => _build(event.target));
    _resolver.addRoutes(routes);
  }

  XRouter addChildren(List<XRouter> children) {
    // this is just to force instanciation of the XRouter.child
    // without it the child router could be in a widget and only instanciated
    // when accessing said widget. If there were resolvers present then they
    // would not be active until we reach the widget and a route could be
    // accessed which the user intended to have a resolver on
    return this;
  }

  void _onNavigationEvent(event) async {
    // this method just calls the right method to get the result for the next event
    if (event is NavigationStart) {
      final parsed = _parse(event.target, event.params, _state.currentUrl);
      final resolved = await _resolve(parsed);
      final activatedRoute = _build(resolved);

      // using a future here so children finish before sending this event
      await Future.value(true);
      _state.addEvent(
        BuildEnd(target: event.target, activatedRoute: activatedRoute),
      );
    } else if (event is BuildEnd) {
      _state.addEvent(NavigationEnd(target: event.target));
    }
  }

  String _parse(String target, Map<String, String>? params, String currentUrl) {
    final parser = XRoutePattern.relative(target, currentUrl);
    return parser.addParameters(params);
  }

  Future<String> _resolve(String target) {
    return _resolver.resolve(target);
  }

  XActivatedRoute _build(String target) {
    final activatedRoute = _activatedRouteBuilder.build(target);
    delegate.initBuild(activatedRoute);
    return activatedRoute;
  }
}
