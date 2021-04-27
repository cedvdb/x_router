import 'dart:async';

import 'package:x_router/src/state/x_router_events.dart';

class XRouterState {
  final StreamController<XRouterEvent> _events = StreamController();
  late final Stream<XRouterEvent> events$ = _events.stream.asBroadcastStream();

  String _currentUrl = '';
  String get currentUrl => _currentUrl;

  addEvent(XRouterEvent event) {
    if (event is NavigationEnd) {
      _currentUrl = event.target;
    }
    _events.add(event);
  }
}
