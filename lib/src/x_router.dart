import 'package:flutter/widgets.dart';
import 'package:x_router/src/delegate/x_delegate.dart';
import 'package:x_router/src/delegate/x_route_information_parser.dart';
import 'package:x_router/src/resolver/x_route_resolver.dart';
import 'package:x_router/src/resolver/x_router_resolver.dart';
import 'package:x_router/src/route/x_activated_route_builder.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';

class XRouter {
  XRouterDelegate delegate;
  XRouteInformationParser parser;
  XRoutingStateNotifier routingStateNotifier;
  XRouterResolver _routerResolver;
  XActivatedRouteBuilder _activatedRouteBuilder;

  XRouter({
    @required List<XRoute> routes,
    List<XRouteResolver> resolvers = const [],
    XRoute notFound,
  }) {
    notFound = notFound ?? XSpecialRoutes.notFoundRoute;
    routingStateNotifier = XRoutingStateNotifier();
    routingStateNotifier.addListener(() => print(routingStateNotifier.value));
    parser = XRouteInformationParser();
    delegate = XRouterDelegate(
      routingStateNotifier: routingStateNotifier,
    );
    _routerResolver = XRouterResolver(
      resolvers: resolvers,
      routes: routes,
      routingStateNotifier: routingStateNotifier,
    );
    _activatedRouteBuilder = XActivatedRouteBuilder(
      routes: routes,
      routingStateNotifier: routingStateNotifier,
      notFoundRoute: notFound,
    );
  }

  goTo(String path) {
    delegate.setNewRoutePath(path);
  }
}
