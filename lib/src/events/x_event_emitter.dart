import 'dart:async';

import 'package:x_router/src/events/x_router_events.dart';

/// Keeps track of the router state
class XEventEmitter {
  XEventEmitter._();

  // not a fan of singleton pattern but since this is kind of a logger it works well
  /// singleton
  static final XEventEmitter instance = XEventEmitter._();

  /// Streams all router events
  late final Stream<XRouterEvent> eventStream =
      _eventController.stream.asBroadcastStream();
  final StreamController<XRouterEvent> _eventController = StreamController();

  /// adds an event to the event stream
  void emit(XRouterEvent event) => _eventController.add(event);
}
