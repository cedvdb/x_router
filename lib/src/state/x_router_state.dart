import 'dart:async';

import 'package:x_router/src/state/x_router_events.dart';

class XRouterState {
  StreamController<XRouterEvent> _events = StreamController();
  Stream<XRouterEvent> get events$ => _events.stream;

  String _currentUrl = '';
  String get currentUrl => _currentUrl;

  addEvent(XRouterEvent event) {
    if (event is NavigationEnd) {
      _currentUrl = event.target;
    }
    _events.add(event);
  }
}
