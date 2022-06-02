import 'package:flutter/material.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';
import 'package:x_router/src/navigated_route/x_navigated_route.dart';
import 'package:x_router/src/router/base_router.dart';
import 'package:x_router/src/router/x_child_router_store.dart';

import '../navigated_route/x_navigated_route_builder.dart';
import '../delegate/x_delegate.dart';
import '../route/x_route.dart';

/// Router that can be used as a child
class XChildRouter implements BaseRouter {
  final BaseRouter _parent;
  @override
  final List<XRoute> routes;

  /// page stack (activatedRoute) builder
  late final XNavigatedRouteBuilder _activatedRouteBuilder =
      XNavigatedRouteBuilder(routes: routes);

  /// renderer
  late final XRouterDelegate _delegate =
      XRouterDelegate(onNewPath: navigate, debugLabel: 'child router');
  @override
  RouterDelegate get delegate => _delegate;

  @override
  late final RouteInformationParser<String> informationParser =
      _parent.informationParser;

  @override
  RouteInformationProvider get informationProvider =>
      _parent.informationProvider;

  late final BackButtonDispatcher _backButtonDispatcher =
      ChildBackButtonDispatcher(_parent.backButtonDispatcher);
  @override
  BackButtonDispatcher get backButtonDispatcher => _backButtonDispatcher;

  late final XChildRouterStore _childRouterStore =
      XChildRouterStore.fromRoutes(this, routes);

  XChildRouter({
    required BaseRouter parent,
    required this.routes,
  }) : _parent = parent;

  XNavigatedRoute navigate(String target) {
    XEventEmitter.instance.emit(ChildNavigationStart(target: target));
    var navigatedRoute = _activatedRouteBuilder.build(target);

    // adds child routers
    if (navigatedRoute.route.children.isNotEmpty) {
      final child = _childRouterStore.findChild(navigatedRoute.route.path)
          as XChildRouter;
      final navigatedRouteChild = child.navigate(target);
      navigatedRoute = navigatedRoute.copyWith(child: navigatedRouteChild);
    } else {
      informationProvider.routerReportsNewRouteInformation(
        RouteInformation(location: navigatedRoute.matchingPath),
      );
    }

    _delegate.render(navigatedRoute);

    XEventEmitter.instance.emit(
      ChildNavigationEnd(
        target: target,
        navigatedRoute: navigatedRoute,
      ),
    );

    return navigatedRoute;
  }
}
