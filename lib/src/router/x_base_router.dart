import 'package:flutter/material.dart';

import 'package:x_router/src/activated_route/x_activated_route_builder.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/router/x_child_router.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

import '../../x_router.dart';

abstract class XRouterBase {
  /// the current state of the navigation
  static final XRouterState _state = XRouterState.instance;

  @protected
  List<XChildRouter> childRouters = [];

  /// the resolver responsible of resolving a route path
  @protected
  late final XRouterResolver resolver = XRouterResolver(
    onStateChanged: () => goTo(_state.currentUrl),
    // resolvers: resolvers,
    // routes: routes,
  );

  /// builds the route up stack
  @protected
  late final XActivatedRouteBuilder activatedRouteBuilder =
      XActivatedRouteBuilder(
    routes: routes,
    isRoot: isRoot,
  );

  /// all the routes for this router
  @protected
  final List<XRoute> routes;

  /// all the routes for this router
  @protected
  final List<XResolver> resolvers;

  /// whether this router is the root resolver or a child / nested one
  @protected
  final bool isRoot;

  // For flutter Router 2: responsible of resolving a string path to (maybe) another
  final XRouteInformationParser informationParser = XRouteInformationParser();
  late final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => goTo(path),
    isRoot: isRoot,
    onDispose: () {},
  );

  static goTo(String target, {Map<String, String>? params}) async {
    _state.addEvent(NavigationStart(target: target, params: params));
  }

  XRouterBase({
    required this.routes,
    this.resolvers = const [],
    required this.isRoot,
  });
}
