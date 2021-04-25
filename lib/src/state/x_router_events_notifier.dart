import 'dart:async';

enum EventType {
  navigation_start,
  resolving_start,
  resolving_end,
  navigation_end,
}

class RouterEvent {
  EventType type;
  String description;

  RouterEvent({
    required this.type,
    required this.description,
  });
}

class RouterEventNotifier {
  static StreamController _events = StreamController();

  static addEvent(EventType type, String description) {
    _events.add(RouterEvent(type: type, description: description));
  }
}
