import 'dart:async';

import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/state/x_router_events.dart';
import 'package:x_router/src/state/x_router_state.dart';

// responsible of keeping track of the history

class XRouterHistory {
  final List<XActivatedRoute> _history = [];
  StreamSubscription? _stateChangeSubscription;

  XActivatedRoute? get previousRoute => _history.elementAt(1);

  XRouterHistory();

  listenToStateChanges() {
    XRouterState.instance.eventStream
        .where((event) => event is NavigationEnd)
        .cast<NavigationEnd>()
        .listen((event) => _history.insert(0, event.activatedRoute));
  }

  dispose() {
    _stateChangeSubscription?.cancel();
  }
}
