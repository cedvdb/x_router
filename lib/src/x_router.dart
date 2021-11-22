import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/history/router_history.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

import 'route/x_page_builder.dart';
import 'route_pattern/x_route_pattern.dart';

/// Handles navigation
///
/// To navigate simply call XRouter.goTo(routes, params) static method.
class XRouter {
  /// the current state of the navigation, with event stream
  static final XRouterState state = XRouterState.instance;

  /// chronological history
  static final XRouterHistory _history = XRouterHistory();

  /// For flutter Router 2: responsible of resolving a string path to (maybe) another
  final XRouteInformationParser informationParser = XRouteInformationParser();

  /// renderer
  final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
  );

  /// the resolver responsible of resolving a route path
  late final XRouterResolver _resolver;

  /// page stack (activatedRoute) builder
  late final XActivatedRouteBuilder _activatedRouteBuilder;

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
    Function(XRouterEvent)? onEvent,
  }) {
    _resolver = XRouterResolver(
      // when the state of a reactive guard changes we resolve the current url
      onStateChanged: () => goTo(state.currentUrl),
      resolvers: resolvers,
    );
    // the page stack (activatedRoute) builder
    _activatedRouteBuilder = XActivatedRouteBuilder(
      routes: routes,
    );
    state.eventStream.listen((event) {
      onEvent?.call(event);
      _onNavigationEvent(event);
    });
  }

  /// goes to a location and adds it to the history
  ///
  /// The upstack is generated with the url, if the url is /route1/route2
  /// the upstack will be [Route1Page, Route2Page]
  static void goTo(
    String target, {
    Map<String, String>? params,
  }) {
    // event emitted so the XRouter instance can take care of it
    state.addEvent(NavigationStart(target: target, params: params));
  }

  /// replace the current history route
  ///
  /// The page stack follows the same process as [goTo]
  static void replace(String target, {Map<String, String>? params}) {
    state.addEvent(NavigationReplaceStart(target: target, params: params));
  }

  /// goTo route above the current one in the page stack if any
  static void pop() {
    if (state.activatedRoute.upstack.isNotEmpty) {
      final up = state.activatedRoute.upstack.first;
      state.addEvent(
          NavigationPopStart(target: up.effectivePath, params: up.pathParams));
    }
  }

  /// goes back chronologically
  static void back() {
    final previousRoute = _history.previousRoute;
    if (previousRoute != null) {
      state.addEvent(
        NavigationBackStart(
          target: previousRoute.effectivePath,
          params: previousRoute.pathParams,
        ),
      );
    }
  }

  void _onNavigationEvent(event) {
    // this method just calls the right method to get the result for the next event
    if (event is NavigationStart) {
      if (event is NavigationReplaceStart) {
        _history.removeFrom(_history.currentRoute);
      } else if (event is NavigationBackStart) {
        _history.removeFrom(_history.previousRoute);
      }
      _navigate(event.target, event.params);
    }
  }

  void _navigate(String target, Map<String, String>? params) {
    final parsed = _parse(target, params, state.currentUrl);
    final resolved = _resolve(parsed, params);
    final activatedRoute =
        _buildStack(resolved.target, builderOverride: resolved.builderOverride);
    _history.add(activatedRoute);
    _render(activatedRoute);
    state.addEvent(NavigationEnd(activatedRoute: activatedRoute));
  }

  /// parses an url by setting its parameter
  ///
  /// if the url starts with ./ will parse relative to current route
  String _parse(String target, Map<String, String>? params, String currentUrl) {
    state.addEvent(UrlParsingStart(
        target: target, params: params, currentUrl: currentUrl));
    final parser = XRoutePattern.maybeRelative(target, currentUrl);
    final parsed = parser.addParameters(params);
    state.addEvent(UrlParsingEnd(target: target));
    return parsed;
  }

  /// goes through all resolvers to see the final endpoint after redirection
  XRouterResolveResult _resolve(String target, Map<String, String>? params) {
    state.addEvent(ResolvingStart(target: target));
    final resolved = _resolver.resolve(target, params);
    state.addEvent(ResolvingEnd(resolved));
    return resolved;
  }

  /// builds the page stack
  XActivatedRoute _buildStack(String target, {XPageBuilder? builderOverride}) {
    state.addEvent(BuildStart(target: target));
    final activatedRoute = _activatedRouteBuilder.build(
      target,
      builderOverride: builderOverride,
    );
    state.addEvent(BuildEnd(activatedRoute: activatedRoute, target: target));
    return activatedRoute;
  }

  /// renders page stack on screen
  void _render(XActivatedRoute activatedRoute) {
    delegate.initRendering();
  }
}
