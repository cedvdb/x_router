import 'dart:collection';

import 'package:x_router/src/activated_route/x_activated_route.dart';

// responsible of keeping track of the history

class XRouterHistory with IterableMixin<XActivatedRoute> {
  // most recent history items added at the start
  final List<XActivatedRoute> _history = [];

  XActivatedRoute get currentRoute =>
      isNotEmpty ? first : XActivatedRoute.nulled();

  XActivatedRoute? get previousRoute => length > 1 ? elementAt(1) : null;

  bool get hasPreviousRoute => previousRoute != null;

  XRouterHistory();

  add(XActivatedRoute activatedRoute) {
    if (activatedRoute.effectivePath != currentRoute.effectivePath) {
      _history.insert(0, activatedRoute);
    }
  }

  removeFrom(XActivatedRoute? activatedRoute) {
    if (activatedRoute == null) return;
    for (var i = 0; i < _history.length; i++) {
      if (_history[i] == activatedRoute) {
        _history.removeAt(0);
        break;
      }
      _history.removeAt(0);
    }
  }

  @override
  Iterator<XActivatedRoute> get iterator => _history.iterator;
}
