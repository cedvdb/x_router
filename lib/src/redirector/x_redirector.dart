import 'package:flutter/widgets.dart';
import 'package:route_parser/route_parser.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_routing_state.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';

/// The redirector redirects if:
/// - a route specifies a redirect property
/// - a route is not found
class XRedirector {
  XRoutingStateNotifier routingStateNotifier;
  List<XRoute> routes;
  XRoute notFoundRoute;

  XRedirector({
    @required this.routes,
    @required this.routingStateNotifier,
    @required this.notFoundRoute,
  }) {
    routingStateNotifier.addListener(_listenToDirectionStart);
  }

  _listenToDirectionStart() {
    if (routingStateNotifier.state.status == XStatus.redirection_start) {
      final dir = _findDirection(routingStateNotifier.state.target);
      routingStateNotifier.redirect(dir);
    }
  }

  // finds the direction when we have a target, we check recursively if the target route
  // has redirection
  String _findDirection(String target) {
    var found = routes.firstWhere(
      (route) => route.match(target, MatchType.exact),
      orElse: () => notFoundRoute,
    );

    if (found.redirect != null) {
      return _findDirection(found.redirect(target));
    }
    return target;
  }
}
