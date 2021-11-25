import 'activated_route/x_activated_route.dart';
import 'activated_route/x_activated_route_builder.dart';
import 'delegate/x_delegate.dart';

/// Router that can be used as a child
class XChildRouter {
  /// page stack (activatedRoute) builder
  late final XActivatedRouteBuilder _activatedRouteBuilder;

  /// renderer
  final XRouterDelegate delegate = XRouterDelegate(
    onNewRoute: (path) => {},
  );

  /// builds the page stack
  XActivatedRoute _buildActivatedRoute(
    String target,
  ) {
    final activatedRoute = _activatedRouteBuilder.build(
      target,
    );
    return activatedRoute;
  }

  navigateNested(String target) {
    final activatedRoute = _activatedRouteBuilder.build(target);
    delegate.initRendering(activatedRoute);
  }
}
