import 'dart:async';

enum EventType {
  navigation_start,
  resolving_start,
  resolving_end,
  navigation_end,
}

class XRouterEvent {
  EventType type;
  String description;

  XRouterEvent({
    required this.type,
    required this.description,
  });
}

class XRouterState {
  StreamController _events = StreamController();
  String currentUrl = '';

  addEvent(EventType type, String description) {
    _events.add(XRouterEvent(type: type, description: description));
  }
}
