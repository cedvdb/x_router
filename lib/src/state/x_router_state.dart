import 'dart:async';

import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/state/x_router_events.dart';

class XRouterState {
  static final XRouterState instance = XRouterState._();
  final StreamController<XRouterEvent> _events = StreamController();
  late final Stream<XRouterEvent> events$ = _events.stream.asBroadcastStream();
  XActivatedRoute? _activatedRoute;
  XActivatedRoute? get activatedRoute => _activatedRoute;

  XRouterState._();

  String _currentUrl = '';
  String get currentUrl => _currentUrl;

  addEvent(XRouterEvent event) {
    if (event is BuildEnd) {
      _activatedRoute = event.activatedRoute;
    }
    if (event is NavigationEnd) {
      _currentUrl = event.target;
    }
    _events.add(event);
  }
}
