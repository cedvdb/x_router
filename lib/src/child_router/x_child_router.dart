import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';
import 'package:x_router/src/route/x_route.dart';
import 'package:x_router/x_router.dart';

import '../activated_route/x_activated_route_builder.dart';
import '../delegate/x_delegate.dart';

/// Router that can be used as a child
class XChildRouter {
  /// page stack (activatedRoute) builder
  late final XActivatedRouteBuilder _activatedRouteBuilder;

  /// renderer
  final XRouterDelegate delegate = XRouterDelegate(
    shouldReportNewRoute: false,
    onNewRoute: (path) => {},
  );

  final XEventEmitter _eventEmitter = XEventEmitter.instance;

  /// the base path is the path where the child router is active
  final String basePath;
  late final XRoutePattern _basePattern;

  XChildRouter({
    required this.basePath,
    required List<XRoute> routes,
  }) {
    _basePattern = XRoutePattern(basePath);
    _activatedRouteBuilder = XActivatedRouteBuilder(routes: routes);
    // the root resolver listens to navigation start and initialize the resolving
    // process, the only thing required here is to init the rendering process
    _eventEmitter.eventStream
        .where((event) => event is ResolvingEnd)
        .cast<ResolvingEnd>()
        .listen((event) => _navigate(event.result.target));
  }

  _navigate(String target) {
    final isNestedRoute = _basePattern.match(target, matchChildren: true);
    if (isNestedRoute) {
      final activatedRoute = _activatedRouteBuilder.build(target);
      delegate.initRendering(activatedRoute);
    }
  }
}