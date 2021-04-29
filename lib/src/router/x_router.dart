import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/parser/x_route_parser.dart';
import 'package:x_router/src/resolver/x_resolver.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/router/x_base_router.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

/// XRouter helper that handles navigation
///
/// For your root router instantiate it with XRouter(...) if you need
/// nested routing you can do so with XRouter.child(...)
///
/// To navigate simply call XRouter.goTo(routes, params) static method.
class XRouter extends XRouterBase {
  /// the current state of the navigation
  final XRouterState _state = XRouterState.instance;

  XRouter({
    required List<XRoute> routes,
    List<XResolver> resolvers = const [],
    Function(XRouterEvent)? onEvent,
  }) : super(isRoot: false, resolvers: resolvers, routes: routes) {
    _state.events$.listen((event) {
      onEvent?.call(event);
      if (isRoot) {
        _onNavigationEvent(event);
      }
    });
  }

  void _onNavigationEvent(event) async {
    // this method just calls the right method to get the result for the next event
    if (event is NavigationStart) {
      _state.addEvent(
        UrlParsingStart(
          target: event.target,
          params: event.params,
          currentUrl: _state.currentUrl,
        ),
      );
    } else if (event is UrlParsingStart) {
      final parsed = _parse(event.target, event.params, _state.currentUrl);
      _state.addEvent(UrlParsingEnd(target: parsed));
    } else if (event is UrlParsingEnd) {
      _state.addEvent(ResolvingStart(target: event.target));
    } else if (event is ResolvingStart) {
      var resolved = await _resolve(event.target);
      _state.addEvent(ResolvingEnd(target: resolved));
    } else if (event is ResolvingEnd) {
      _state.addEvent(BuildStart(target: event.target));
    } else if (event is BuildStart) {
      final activatedRoute = _build(event.target);
      // we use a future here so the navigation end happens after the
      // children have processed their build event, since those
      // will happen in sync before this future.
      Future.value(null).then((_) {
        _state.addEvent(
            BuildEnd(target: event.target, activatedRoute: activatedRoute));
      });
    }
  }

  String _parse(String target, Map<String, String>? params, String currentUrl) {
    final parser = XRouteParser.relative(target, currentUrl);
    return parser.addParameters(params);
  }

  Future<String> _resolve(String target) {
    return resolver.resolve(target);
  }

  XActivatedRoute _build(String target) {
    final activatedRoute = activatedRouteBuilder.build(target);
    delegate.initBuild(activatedRoute);
    return activatedRoute;
  }
}
