import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

/// XRouter helper that handles navigation
///
/// For your root router instantiate it with XRouter(...) if you need
/// nested routing you can do so with XRouter.child(...)
///
/// To navigate simply call XRouter.goTo(routes, params) static method.
class XRouter {
  static final XRouterState _state = XRouterState();
  static final XRouterResolver _resolver = XRouterResolver(
    onStateChanged: () => goTo(_state.currentUrl),
    routerState: _state,
  );
  late final XActivatedRouteBuilder _activatedRouteBuilder =
      XActivatedRouteBuilder(routes: routes);
  final List<XRoute> routes;
  // whether this router is the root resolver or a child / nested one
  final bool _isRoot;

  // For flutter Router 2: responsible of resolving a string path to (maybe) another
  final XRouteInformationParser informationParser = XRouteInformationParser();
  late final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
    isRoot: _isRoot,
    onDispose: () {},
  );

  XRouter._({
    required this.routes,
    List<XResolver> resolvers = const [],
    required bool isRoot,
    Function(XRouterEvent)? onEvent,
  }) : _isRoot = isRoot {
    // when the resolver has modified the states this runs
    _resolver.addResolvers(resolvers);
    _resolver.addRouteResolvers(routes);
    _state.events$.listen(onEvent);
    _state.events$
        .where((event) => event is BuildStart)
        .listen((ev) => _build(ev as BuildStart));
  }

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
    Function(XRouterEvent)? onEvent,
  }) : this._(
          isRoot: true,
          routes: routes,
          resolvers: resolvers,
          onEvent: onEvent,
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

  static goTo(String target, {Map<String, String>? params}) async {
    // the below part is the common part to all router whether
    // those are nested or not.
    // nav starts
    _state.addEvent(NavigationStart(target: target, params: params));
    // parsing
    _state.addEvent(UrlParsingStart(
      target: target,
      params: params,
      currentUrl: _state.currentUrl,
    ));
    final parser = XRouteParser.relative(target, _state.currentUrl);
    target = parser.addParameters(params);
    _state.addEvent(UrlParsingEnd(target: target));
    // resolving
    _state.addEvent(
        ResolvingStart(target: target, resolvers: _resolver.resolvers));
    final resolved = await _resolver.resolve(target);
    _state.addEvent(ResolvingEnd(target: resolved));
    // the rest happens in instances of XRouter in the _build
    _state.addEvent(BuildStart(target: target));
  }

  void _build(BuildStart buildStartEvent) {
    final target = buildStartEvent.target;
    _state.addEvent(ActivatedRouteBuildStart(isRoot: _isRoot, target: target));
    final activatedRoute = _activatedRouteBuilder.build(target);
    delegate.initBuild(activatedRoute);
    _state.addEvent(ActivatedRouteBuildEnd(
        isRoot: _isRoot, activatedRoute: activatedRoute, target: target));

    if (_isRoot) {
      // we use a future here so the navigation end happens after the
      // children have processed their build event, since those
      // will happen in sync before this future.
      Future.value(null).then((_) {
        _state.addEvent(BuildEnd(target: target));
        _state.addEvent(NavigationEnd(target: target));
      });
    }
  }
}
