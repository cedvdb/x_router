import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/history/router_history.dart';
import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/navigated_route/x_navigated_route_builder.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver_result.dart';
import 'package:x_router/src/router/x_child_router.dart';
import 'package:x_router/x_router.dart';

import '../route/x_page_builder.dart';
import 'base_router.dart';
import 'x_child_router_store.dart';

// Note to the reader
//
// The process of navigation goes like this:
// 1. parse target url
// 2. resolve target url into maybe another (redirect)
// 3. build the page stack (poppableStack)
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
class XRouter implements BaseRouter {
  @override
  final List<XRoute> routes;

  final List<XResolver> resolvers;

  /// emits the different steps of the navigation
  final XEventEmitter _eventEmitter = XEventEmitter.instance;

  /// streams all router event
  Stream<XRouterEvent> get eventStream => _eventEmitter.eventStream;

  /// chronological history
  final _history = XRouterHistory();

  XRouterHistory get history => _history;

  /// For flutter Router: responsible of resolving a string path to (maybe) another
  /// data representation.
  final _informationParser = XRouteInformationParser();
  @override
  RouteInformationParser<String> get informationParser => _informationParser;

  /// renderer
  late final _delegate = XRouterDelegate(onNewPath: goTo);
  @override
  RouterDelegate<String> get delegate => _delegate;

  late final _informationProvider = PlatformRouteInformationProvider(
    initialRouteInformation: RouteInformation(
      location: history.isEmpty ? null : history.currentUrl,
    ),
  );
  @override
  RouteInformationProvider get informationProvider => _informationProvider;

  final _backButtonDispatcher = RootBackButtonDispatcher();
  @override
  BackButtonDispatcher get backButtonDispatcher => _backButtonDispatcher;

  /// the resolver responsible of resolving a route path (redirects)
  late final XRouterResolver _resolver = XRouterResolver(
    onEvent: _eventEmitter.emit,
    resolvers: resolvers,
    onStateChanged: _refresh,
  );

  /// page stack (activatedRoute) builder
  late final XNavigatedRouteBuilder _activatedRouteBuilder =
      XNavigatedRouteBuilder(routes: routes);

  /// all child routers
  late final XChildRouterStore _childRouterStore =
      XChildRouterStore.fromRootRoutes(this, routes);
  XChildRouterStore get childRouterStore => _childRouterStore;

  StreamSubscription? _eventStreamSubscription;

  XRouter({
    required this.routes,
    this.resolvers = const [],
  });

  /// goes to a location and adds it to the history
  ///
  /// The poppableStack is generated with the url, if the url is /route1/route2
  /// the poppableStack will be [Route1Page, Route2Page]
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
    if (_history.currentRoute.poppableStack.isNotEmpty) {
      final up = _history.currentRoute.poppableStack.first;
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
    XNavigatedRoute? removeHistoryThrough,
  }) {
    final parsed = _parseUrl(target, params);
    final resolved = _resolve(parsed);
    final navigatedRoute = _buildActivatedRoute(
      resolved.target,
      builderOverride: resolved.builderOverride,
    );
    var historyPath = navigatedRoute.matchingPath;
    _render(navigatedRoute);

    if (navigatedRoute.route.children.isNotEmpty) {
      final child = _childRouterStore.findChild(navigatedRoute.route.path)
          as XChildRouter;
      final navigatedRouteChild = child.navigate(resolved.target);
    }
    _history.removeThrough(removeHistoryThrough);
    _history.add(activatedRoute);
    _eventEmitter.emit(
      NavigationEnd(
        navigatedRoute: navigatedRoute,
        target: target,
        previous: _history.previousRoute,
      ),
    );
  }

  /// parses an url by setting its parameter
  String _parseUrl(String target, Map<String, String>? params) {
    _eventEmitter.emit(UrlParsingStart(target: target, params: params));
    // if url starts with ./ then it's relative to current url
    final parser = XRoutePattern.maybeRelative(target, _history.currentUrl);
    final parsed = parser.addParameters(params);
    _eventEmitter.emit(UrlParsingEnd(target: target, parsed: parsed));
    return parsed;
  }

  /// goes through all resolvers to see the final endpoint after redirection
  XRouterResolveResult _resolve(String target) {
    _eventEmitter.emit(ResolvingStart(target: target));
    final resolved = _resolver.resolve(target);
    _eventEmitter.emit(ResolvingEnd(target: target, result: resolved));
    return resolved;
  }

  // note: should builderOverride stay ? It is annoying to have a builder
  // popping up in the parsing process. It is however very useful here

  /// builds the page stack
  /// if [builderOverride] is present, the builder of activated
  /// route will be [builderOverride] instead of the XRoute builder
  /// This is to allow pages to be in a loading state
  XNavigatedRoute _buildActivatedRoute(
    String target, {
    XPageBuilder? builderOverride,
  }) {
    _eventEmitter.emit(BuildStart(target: target));
    final activatedRoute = _activatedRouteBuilder.build(
      target,
      builderOverride: builderOverride,
    );

    _eventEmitter
        .emit(BuildEnd(activatedRoute: activatedRoute, target: target));
    return activatedRoute;
  }

  /// renders page stack on screen
  void _render(XNavigatedRoute activatedRoute) {
    _delegate.render(activatedRoute);
  }

  /// dispose of this router, usually that method is never
  /// called because the router should always be active in the
  /// lifecycle of an application
  dispose() {
    _eventStreamSubscription?.cancel();
    _resolver.dispose();
  }
}
