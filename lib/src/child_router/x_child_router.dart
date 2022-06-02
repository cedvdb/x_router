import 'package:flutter/material.dart';
import 'package:x_router/src/router/base_router.dart';

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
  late final XRouterDelegate _delegate = XRouterDelegate(onNewPath: null);
  @override
  RouterDelegate get delegate => _delegate;

  @override
  late final RouteInformationParser<String> informationParser =
      _parent.informationParser;

  @override
  late final RouteInformationProvider informationProvider =
      _parent.informationProvider;

  late final BackButtonDispatcher _backButtonDispatcher =
      ChildBackButtonDispatcher(_parent.backButtonDispatcher);
  @override
  BackButtonDispatcher get backButtonDispatcher => _backButtonDispatcher;

  XChildRouter({
    required BaseRouter parent,
    required this.routes,
  }) : _parent = parent;

  void navigate(String target) {
    final activatedRoute = _activatedRouteBuilder.build(target);
    _delegate.render(activatedRoute);
  }
}
