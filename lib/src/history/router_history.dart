import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

  void add(XActivatedRoute activatedRoute) {
    if (activatedRoute.effectivePath != currentRoute.effectivePath) {
      _history.insert(0, activatedRoute);
    }
  }

  // removes history from the current route to the [activatedRoute] included.
  void removeThrough(XActivatedRoute? activatedRoute) {
    if (activatedRoute == null) return;
    for (var i = 0; i < _history.length; i++) {
      if (_history[i] == activatedRoute) {
        _removeLast();
        break;
      }
      _removeLast();
    }
  }

  void _removeLast() {
    // should remove from browser history here too
    _history.removeAt(0);
  }

  @override
  Iterator<XActivatedRoute> get iterator => _history.iterator;
}
