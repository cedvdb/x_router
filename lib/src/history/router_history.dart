import 'dart:collection';

import 'package:x_router/src/navigated_route/x_navigated_route.dart';

// responsible of keeping track of the history

class XRouterHistory with IterableMixin<XNavigatedRoute> {
  // most recent history items added at the start
  final List<XNavigatedRoute> _history = [];

  XNavigatedRoute get currentRoute =>
      isNotEmpty ? first : XNavigatedRoute.nulled();

  XNavigatedRoute? get previousRoute => length > 1 ? elementAt(1) : null;

  String get currentUrl => currentRoute.effectivePath;

  bool get hasPreviousRoute => previousRoute != null;

  XRouterHistory();

  void add(XNavigatedRoute activatedRoute) {
    if (activatedRoute.effectivePath != currentRoute.effectivePath) {
      _history.insert(0, activatedRoute);
    }
  }

  // removes history from the current route to the [activatedRoute] included.
  void removeThrough(XNavigatedRoute? activatedRoute) {
    if (activatedRoute == null) return;
    for (var i = 0; i < _history.length; i++) {
      if (_history[i] == activatedRoute) {
        _removeLast();
        break;
      }
      _removeLast();
    }
  }

  void clear() {
    _history.clear();
  }

  void _removeLast() {
    // should remove from browser history here too
    _history.removeAt(0);
  }

  @override
  Iterator<XNavigatedRoute> get iterator => _history.iterator;
}
