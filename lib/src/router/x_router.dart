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
  );

  /// page stack (activatedRoute) builder
  late final XNavigatedRouteBuilder _navigatedRouteBuilder =
      XNavigatedRouteBuilder(routes: routes);

  /// all child routers
  late final XChildRouterStore _childRouterStore =
      XChildRouterStore.forParent(this);
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
  Future<XNavigatedRoute> goTo(String target, {Map<String, String>? params}) {
    return _navigate(target, params);
  }

  /// replace the current history route
  ///
  /// The page stack follows the same process as [goTo]
  Future<XNavigatedRoute> replace(String target,
      {Map<String, String>? params}) {
    return _navigate(
      target,
      params,
      removeHistoryThrough: _history.currentRoute,
    );
  }

  /// goes back chronologically
  Future<XNavigatedRoute?> back() async {
    final previousRoute = _history.previousRoute;
    if (previousRoute != null) {
      return _navigate(
        previousRoute.effectivePath,
        previousRoute.pathParams,
        removeHistoryThrough: previousRoute,
      );
    }
    return null;
  }

  /// alias for goTo(currentUrl)
  Future<XNavigatedRoute> refresh() {
    return _navigate(
      _history.currentRoute.effectivePath,
      _history.currentRoute.pathParams,
    );
  }

  Future<XNavigatedRoute> _navigate(
    String target,
    Map<String, String>? params, {
    XNavigatedRoute? removeHistoryThrough,
  }) async {
    _eventEmitter.emit(NavigationStart(target: target));
    final parsed = _parseUrl(target, params);
    final resolved = await _resolve(parsed);
    target = resolved.target;
    // this is the stack of page for the current router
    var navigatedRoute = _buildNavigatedRoute(
      resolved.target,
      builderOverride: resolved.builderOverride,
    );

    // adds child routers
    if (navigatedRoute.route.children.isNotEmpty) {
      final child = _childRouterStore.findChild(navigatedRoute.route.path)
          as XChildRouter;
      final navigatedRouteChild = child.navigate(target);
      navigatedRoute = navigatedRoute.copyWith(child: navigatedRouteChild);
    }
    _history.removeThrough(removeHistoryThrough);
    _history.add(navigatedRoute);

    _render(navigatedRoute);
    _eventEmitter.emit(
      NavigationEnd(
        target: resolved.target,
        navigatedRoute: navigatedRoute,
        previous: _history.previousRoute,
      ),
    );
    return navigatedRoute;
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
  Future<XRouterResolveResult> _resolve(String target) async {
    _eventEmitter.emit(ResolvingStart(target: target));
    final resolved = await _resolver.resolve(target);
    _eventEmitter.emit(ResolvingEnd(target: target, result: resolved));
    return resolved;
  }

  // note: should builderOverride stay ? It is annoying to have a builder
  // popping up in the parsing process. It is however very useful here

  /// builds the page stack
  /// if [builderOverride] is present, the builder of activated
  /// route will be [builderOverride] instead of the XRoute builder
  /// This is to allow pages to be in a loading state
  XNavigatedRoute _buildNavigatedRoute(
    String target, {
    XPageBuilder? builderOverride,
  }) {
    _eventEmitter.emit(BuildStart(target: target));
    final activatedRoute = _navigatedRouteBuilder.build(target);
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
  }
}
