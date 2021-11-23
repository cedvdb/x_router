import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/history/router_history.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/route/x_route.dart';
import 'events/x_router_events.dart';
import 'route/x_page_builder.dart';
import 'route_pattern/x_route_pattern.dart';

/// Handles navigation
///
/// To navigate simply call XRouter.goTo(routes, params) static method.
class XRouter {
  /// emits the different steps of the navigation with event stream
  static final XEventEmitter _eventEmitter = XEventEmitter.instance;

  /// streams all router event
  static Stream<XRouterEvent> get eventStream => _eventEmitter.eventStream;

  /// chronological history
  static final XRouterHistory _history = XRouterHistory();

  /// For flutter Router: responsible of resolving a string path to (maybe) another
  /// data representation.
  final XRouteInformationParser informationParser = XRouteInformationParser();

  /// renderer
  final XRouterDelegate delegate = XRouterDelegate(
    // new route detected by the OS
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
      onStateChanged: () => refresh(),
      resolvers: resolvers,
    );
    // the page stack (activatedRoute) builder
    _activatedRouteBuilder = XActivatedRouteBuilder(
      routes: routes,
    );
    _eventEmitter.eventStream.listen((event) {
      onEvent?.call(event);
      _onNavigationEvent(event);
    });
  }

  /// goes to a location and adds it to the history
  ///
  /// The upstack is generated with the url, if the url is /route1/route2
  /// the upstack will be [Route1Page, Route2Page]
  static void goTo(String target, {Map<String, String>? params}) {
    // event emitted so the XRouter instance can take care of it
    _eventEmitter.addEvent(NavigationStart(target: target, params: params));
  }

  /// replace the current history route
  ///
  /// The page stack follows the same process as [goTo]
  static void replace(String target, {Map<String, String>? params}) {
    _eventEmitter
        .addEvent(NavigationReplaceStart(target: target, params: params));
  }

  /// goTo route above the current one in the page stack if any
  static void pop() {
    if (_history.currentRoute.upstack.isNotEmpty) {
      final up = _history.currentRoute.upstack.first;
      _eventEmitter.addEvent(
          NavigationPopStart(target: up.effectivePath, params: up.pathParams));
    }
  }

  /// goes back chronologically
  static void back() {
    final previousRoute = _history.previousRoute;
    if (previousRoute != null) {
      _eventEmitter.addEvent(
        NavigationBackStart(
          target: previousRoute.effectivePath,
          params: previousRoute.pathParams,
        ),
      );
    }
  }

  /// alias for goTo(currentUrl)
  static void refresh() {
    // event emitted so the XRouter instance can take care of it
    _eventEmitter.addEvent(
      NavigationStart(
        target: _history.currentRoute.effectivePath,
        params: _history.currentRoute.pathParams,
      ),
    );
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

  void _navigate(String target, Map<String, String>? params) async {
    final parsed = _parseUrl(target, params);
    final activatedRoute = _buildActivatedRoute(parsed);
    _history.add(activatedRoute);
    _render(activatedRoute);
    _eventEmitter.addEvent(
        NavigationEnd(activatedRoute: activatedRoute, target: target));
  }

  /// parses an url by setting its parameter
  String _parseUrl(String target, Map<String, String>? params) {
    _eventEmitter.addEvent(UrlParsingStart(target: target, params: params));
    final parser = XRoutePattern(target);
    final parsed = parser.addParameters(params);
    _eventEmitter.addEvent(UrlParsingEnd(target: target, parsed: parsed));
    return parsed;
  }

  /// goes through all resolvers to see the final endpoint after redirection
  XRouterResolveResult _resolve(String target) {
    _eventEmitter.addEvent(ResolvingStart(target: target));
    final resolved = _resolver.resolve(target);
    _eventEmitter.addEvent(ResolvingEnd(target: target, result: resolved));
    return resolved;
  }

  // note: should builderOverride stay ?

  /// builds the page stack
  /// if [builderOverride] is present, the builder of activated
  /// route will be [builderOverride] instead of the XRoute builder
  /// This is to allow pages to be in a loading state
  XActivatedRoute _buildActivatedRoute(
    String target, {
    XPageBuilder? builderOverride,
  }) {
    final activatedRoute = _activatedRouteBuilder.build(
      target,
      builderOverride: builderOverride,
    );

    return activatedRoute;
  }

  /// renders page stack on screen
  void _render(XActivatedRoute activatedRoute) {
    delegate.initRendering(activatedRoute);
  }
}
