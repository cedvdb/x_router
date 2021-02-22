import 'package:flutter/widgets.dart';
import 'package:route_parser/route_parser.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/src/state/x_routing_state.dart';
import 'package:x_router/src/state/x_routing_state_notifier.dart';

/// The redirector redirects if:
/// - a route specifies a redirectTo property
/// - a route is not found
class XRedirector {
  XRoutingStateNotifier routingStateNotifier;
  List<XRoute> routes;
  XRoute notFoundRoute;

  XRedirector(
      {@required this.routes,
      @required this.routingStateNotifier,
      @required this.notFoundRoute}) {
    routingStateNotifier.addListener(_listenToDirectionStart);
  }

  _listenToDirectionStart() {
    if (routingStateNotifier.state.status == XStatus.redirection_start) {
      final dir = _findDirection(routingStateNotifier.state.target);
      routingStateNotifier.redirect(dir);
    }
  }

  String _findDirection(String target) {
    var maybeFound =
        routes.firstWhere((route) => route.match(target, MatchType.exact));
    if (maybeFound == null) {
      maybeFound = notFoundRoute;
    }
    if (maybeFound.redirect != null) {
      return _findDirection(maybeFound.redirect(target));
    }
    return target;
  }
}
