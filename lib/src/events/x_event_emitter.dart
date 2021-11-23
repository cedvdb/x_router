import 'dart:async';

import 'package:x_router/src/events/x_router_events.dart';

/// Keeps track of the router state
class XEventEmitter {
  // singleton
  static final XEventEmitter instance = XEventEmitter._();
  XEventEmitter._();

  /// Streams all router events
  late final Stream<XRouterEvent> eventStream =
      _eventController.stream.asBroadcastStream();
  final StreamController<XRouterEvent> _eventController = StreamController();

  /// adds an event to the event stream
  void addEvent(XRouterEvent event) => _eventController.add(event);
}
