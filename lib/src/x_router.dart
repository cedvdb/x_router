import 'package:flutter/cupertino.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/child_router/x_child_router_store.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/history/router_history.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/x_router.dart';

import 'route/x_page_builder.dart';

// Note to the reader
//
// The process of navigation goes like this:
// 1. parse target url
// 2. resolve target url into maybe another (redirect)
// 3. build the page stack (downStack)
// 4. add to history
// 5. render

/// Handles navigation
///
/// One instance of XRouter should be created by an application.
///
/// To navigate use one of:
///   - goTo
///   - replace
///   - back
///   - pop (This is usually handled by flutter)
class XRouter {
  /// emits the different steps of the navigation
  final XEventEmitter _eventEmitter = XEventEmitter.instance;

  /// streams all router event
  Stream<XRouterEvent> get eventStream => _eventEmitter.eventStream;

  /// chronological history
  final XRouterHistory _history = XRouterHistory();

  XRouterHistory get history => _history;

  /// For flutter Router: responsible of resolving a string path to (maybe) another
  /// data representation.
  final XRouteInformationParser _informationParser = XRouteInformationParser();
  RouteInformationParser<String> get informationParser => _informationParser;

  /// renderer
  late final XRouterDelegate _delegate = XRouterDelegate(
    // new route detected by the OS
    onNewRoute: (path) => goTo(path),
  );
  RouterDelegate<String> get delegate => _delegate;

  late final RouteInformationProvider informationProvider =
      PlatformRouteInformationProvider(
    initialRouteInformation: RouteInformation(
      location: history.isEmpty ? null : history.currentUrl,
    ),
  );

  /// the resolver responsible of resolving a route path (redirects)
  late final XRouterResolver _resolver;

  /// page stack (activatedRoute) builder
  late final XActivatedRouteBuilder _activatedRouteBuilder;

  /// all child routers
  late final XChildRouterStore _childRouterStore;
  XChildRouterStore get childRouterStore => _childRouterStore;

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
  }) {
    final allResolvers = [...resolvers];

    for (final route in routes) {
      allResolvers.addAll(route.findChildResolvers());
    }

    _resolver = XRouterResolver(
      onEvent: _eventEmitter.addEvent,
      resolvers: allResolvers,
      onStateChanged: _refresh,
    );

    _childRouterStore = XChildRouterStore.fromRootRoutes(routes);
    // the page stack (activatedRoute) builder
    _activatedRouteBuilder = XActivatedRouteBuilder(
      routes: routes,
    );
  }

  /// goes to a location and adds it to the history
  ///
  /// The downStack is generated with the url, if the url is /route1/route2
  /// the downStack will be [Route1Page, Route2Page]
  void goTo(String target, {Map<String, String>? params}) {
    _navigate(target, params);
  }

  /// replace the current history route
  ///
  /// The page stack follows the same process as [goTo]
  void replace(String target, {Map<String, String>? params}) {
    _navigate(
      target,
      params,
      removeHistoryThrough: _history.currentRoute,
    );
  }

  /// [goTo] route above the current one in the page stack if any
  /// Usually this method is called by flutter. Consider using [back]
  /// to go back chronologically
  void pop() {
    if (_history.currentRoute.downStack.isNotEmpty) {
      final up = _history.currentRoute.downStack.first;
      _navigate(
        up.effectivePath,
        up.pathParams,
      );
    }
  }

  /// goes back chronologically
  void back() {
    final previousRoute = _history.previousRoute;
    if (previousRoute != null) {
      _navigate(
        previousRoute.effectivePath,
        previousRoute.pathParams,
        removeHistoryThrough: previousRoute,
      );
    }
  }

  /// alias for goTo(currentUrl)
  void _refresh() {
    _navigate(
      _history.currentRoute.effectivePath,
      _history.currentRoute.pathParams,
    );
  }

  void _navigate(
    String target,
    Map<String, String>? params, {
    XActivatedRoute? removeHistoryThrough,
  }) {
    _eventEmitter.addEvent(NavigationStart(
      target: target,
      params: params,
      removeHistoryThrough: removeHistoryThrough,
    ));
    final parsed = _parseUrl(target, params);
    final resolved = _resolve(parsed);
    final activatedRoute = _buildActivatedRoute(
      resolved.target,
      builderOverride: resolved.builderOverride,
    );
    _history.removeThrough(removeHistoryThrough);
    _history.add(activatedRoute);
    _render(activatedRoute);

    _eventEmitter.addEvent(
      NavigationEnd(
        activatedRoute: activatedRoute,
        target: target,
        previous: _history.previousRoute,
      ),
    );
  }

  /// parses an url by setting its parameter
  String _parseUrl(String target, Map<String, String>? params) {
    _eventEmitter.addEvent(UrlParsingStart(target: target, params: params));
    // if url starts with ./ then it's relative to current url
    final parser = XRoutePattern.maybeRelative(target, _history.currentUrl);
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

  // note: should builderOverride stay ? It is annoying to have a builder
  // popping up in the parsing process. It is however very useful here

  /// builds the page stack
  /// if [builderOverride] is present, the builder of activated
  /// route will be [builderOverride] instead of the XRoute builder
  /// This is to allow pages to be in a loading state
  XActivatedRoute _buildActivatedRoute(
    String target, {
    XPageBuilder? builderOverride,
  }) {
    _eventEmitter.addEvent(BuildStart(target: target));
    final activatedRoute = _activatedRouteBuilder.build(
      target,
      builderOverride: builderOverride,
    );

    _eventEmitter
        .addEvent(BuildEnd(activatedRoute: activatedRoute, target: target));
    return activatedRoute;
  }

  /// renders page stack on screen
  void _render(XActivatedRoute activatedRoute) {
    _delegate.render(activatedRoute);
  }

  /// dispose of this router, usually that method is never
  /// called because the router should always be active in the
  /// lifecycle of an application
  dispose() {
    _resolver.dispose();
  }
}
