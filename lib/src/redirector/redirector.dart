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

  XRedirector({this.routes, this.routingStateNotifier}) {
    routingStateNotifier.addListener(_listenToDirectionStart);
  }

  _listenToDirectionStart() {
    if (routingStateNotifier.state.status == XStatus.direction_start) {
      _redirect(routingStateNotifier.state.target);
    }
  }

  _redirect(String target) {
    final found =
        routes.firstWhere((route) => route.match(target, MatchType.exact));
    // todo
  }
}
