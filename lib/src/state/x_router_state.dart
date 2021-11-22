import 'dart:async';

import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/x_router.dart';

/// Keeps track of the router state
class XRouterState {
  // singleton
  static final XRouterState instance = XRouterState._();
  XRouterState._();

  /// Streams all router events
  late final Stream<XRouterEvent> eventStream =
      _eventController.stream.asBroadcastStream();
  final StreamController<XRouterEvent> _eventController = StreamController();

  /// the current activated route
  XActivatedRoute get activatedRoute => _activatedRoute;
  XActivatedRoute _activatedRoute = XActivatedRoute.nulled();

  /// current url path
  String get currentUrl => _activatedRoute.effectivePath;

  /// adds an event to the event stream
  void addEvent(XRouterEvent event) {
    if (event is NavigationEnd) {
      _activatedRoute = event.activatedRoute;
    }
    _eventController.add(event);
  }
}
