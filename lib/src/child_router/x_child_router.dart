import 'package:flutter/material.dart';
import 'package:x_router/src/router/base_router.dart';

import '../activated_route/x_activated_route_builder.dart';
import '../delegate/x_delegate.dart';
import '../route/x_route.dart';

/// Router that can be used as a child
class XChildRouter implements BaseRouter {
  final BaseRouter _parent;

  @override
  final List<XRoute> routes;

  /// page stack (activatedRoute) builder
  late final XActivatedRouteBuilder _activatedRouteBuilder =
      XActivatedRouteBuilder(routes: routes);

  /// renderer
  late final XRouterDelegate _delegate = XRouterDelegate();
  @override
  RouterDelegate get delegate => _delegate;

  @override
  final RouteInformationParser<String> informationParser;

  @override
  final RouteInformationProvider informationProvider;

  late final BackButtonDispatcher _backButtonDispatcher =
      ChildBackButtonDispatcher(_parent.backButtonDispatcher);
  @override
  BackButtonDispatcher get backButtonDispatcher => _backButtonDispatcher;

  XChildRouter({
    required this.informationParser,
    required this.informationProvider,
    required BaseRouter parent,
    required this.routes,
  }) : _parent = parent;

  navigate(String target) {
    final activatedRoute = _activatedRouteBuilder.build(target);
    _delegate.render(activatedRoute);
  }
}
