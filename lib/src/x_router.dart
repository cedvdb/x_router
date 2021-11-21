import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
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
  late final XRouterResolver _resolver;

  /// builds the route up stack
  late final XActivatedRouteBuilder _activatedRouteBuilder =
      XActivatedRouteBuilder(
    routes: _routes,
  );

  /// all the routes for this router
  final List<XRoute> _routes;

  // For flutter Router 2: responsible of resolving a string path to (maybe) another
  final XRouteInformationParser informationParser = XRouteInformationParser();
  late final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
    onDispose: () {},
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
  }) : _routes = routes {
    _resolver = XRouterResolver(
      // when the state changes we resolve the current url
      onStateChanged: () => goTo(_state.currentUrl),
      resolvers: resolvers,
      routes: routes,
    );

    _state.events$.listen((event) {
      onEvent?.call(event);
      _onNavigationEvent(event);
    });
  }

  void _onNavigationEvent(event) {
    // this method just calls the right method to get the result for the next event
    if (event is NavigationStart) {
      final parsed = _parse(event.target, event.params, _state.currentUrl);
      final resolved = _resolve(parsed);
      final activatedRoute = _build(resolved);
      delegate.initBuild(activatedRoute);
      _state.addEvent(NavigationEnd(target: event.target));
    }
  }

  String _parse(String target, Map<String, String>? params, String currentUrl) {
    _state.addEvent(UrlParsingStart(
        target: target, params: params, currentUrl: currentUrl));
    final parser = XRoutePattern.relative(target, currentUrl);
    final parsed = parser.addParameters(params);
    _state.addEvent(UrlParsingEnd(target: target));
    return parsed;
  }

  XRouterResolveResult _resolve(String target) {
    _state.addEvent(ResolvingStart(target: target));
    final resolved = _resolver.resolve(target);
    _state.addEvent(ResolvingEnd(resolved));
    return resolved;
  }

  XActivatedRoute _build(XRouterResolveResult resolved) {
    _state.addEvent(BuildStart(target: resolved.target));

    final activatedRoute = _activatedRouteBuilder.build(resolved);
    delegate.initBuild(activatedRoute);
    _state.addEvent(
        BuildEnd(activatedRoute: activatedRoute, target: resolved.target));
    return activatedRoute;
  }
}
