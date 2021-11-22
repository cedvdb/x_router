import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

import 'route_pattern/x_route_pattern.dart';

/// Handles navigation
///
/// To navigate simply call XRouter.goTo(routes, params) static method.
class XRouter {
  /// the current state of the navigation, with event stream
  static XRouterState get state => XRouterState.instance;

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

  static void goTo(
    String target, {
    Map<String, String>? params,
  }) {
    state.addEvent(NavigationStart(target: target, params: params));
  }

  static void push(String target, {Map<String, String>? params}) {
    state.addEvent(
        NavigationStart(target: target, params: params, forcePush: true));
  }

  static void back() {
    throw 'unimplemented';
  }

  static void pop() {
    if (state.activatedRoute.upstack.length >= 1) {
      goTo(state.activatedRoute.upstack.last.effectivePath);
    }
  }

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
    Function(XRouterEvent)? onEvent,
  }) : _routes = routes {
    _resolver = XRouterResolver(
      // when the state changes we resolve the current url
      onStateChanged: () => goTo(state.currentUrl),
      resolvers: resolvers,
      routes: routes,
    );

    state.eventStream.listen((event) {
      onEvent?.call(event);
      _onNavigationEvent(event);
    });
  }

  void _onNavigationEvent(event) {
    // this method just calls the right method to get the result for the next event
    if (event is NavigationStart) {
      final parsed = _parse(event.target, event.params, state.currentUrl);
      final resolved = _resolve(parsed);
      XActivatedRoute activatedRoute;
      if (event.forcePush) {
        activatedRoute =
            _build(resolved.target, builderOverride: resolved.builder);
      } else {
        activatedRoute =
            _push(resolved.target, builderOverride: resolved.builder);
      }
      _render(activatedRoute);
      state.addEvent(NavigationEnd(activatedRoute: activatedRoute));
    }
  }

  /// parses an url by setting its parameter
  ///
  /// if the url starts with ./ will parse relative to current route
  String _parse(String target, Map<String, String>? params, String currentUrl) {
    state.addEvent(UrlParsingStart(
        target: target, params: params, currentUrl: currentUrl));
    final parser = XRoutePattern.relative(target, currentUrl);
    final parsed = parser.addParameters(params);
    state.addEvent(UrlParsingEnd(target: target));
    return parsed;
  }

  /// goes through all resolvers to see the final endpoint after redirection
  XRouterResolveResult _resolve(String target) {
    state.addEvent(ResolvingStart(target: target));
    final resolved = _resolver.resolve(target);
    state.addEvent(ResolvingEnd(resolved));
    return resolved;
  }

  /// builds the page stack
  XActivatedRoute _build(String target, {XPageBuilder? builderOverride}) {
    state.addEvent(BuildStart(target: target));
    XActivatedRoute activatedRoute;
    activatedRoute = _activatedRouteBuilder.build(
      target,
      builderOverride: builderOverride,
    );
    state.addEvent(BuildEnd(activatedRoute: activatedRoute, target: target));
    return activatedRoute;
  }

  /// push new activated route on top of the current stack
  XActivatedRoute _push(String target, {XPageBuilder? builderOverride}) {
    state.addEvent(BuildStart(target: target));
    XActivatedRoute activatedRoute;
    activatedRoute = _activatedRouteBuilder.add(
      target,
      builderOverride: builderOverride,
    );
    state.addEvent(BuildEnd(activatedRoute: activatedRoute, target: target));
    return activatedRoute;
  }

  /// renders page stack on screen
  void _render(XActivatedRoute activatedRoute) {
    state.addEvent(XRenderingStart());
    delegate.initRendering();
    state.addEvent(XRenderingEnd());
  }
}
