import 'dart:collection';

import 'package:x_router/src/navigated_route/x_navigated_route.dart';

// responsible of keeping track of the history

class History with IterableMixin<NavigatedRoute> {
  // most recent history items added at the start
  final List<NavigatedRoute> _history = [];

  NavigatedRoute get currentRoute =>
      isNotEmpty ? first : NavigatedRoute.nulled();

  NavigatedRoute? get previousRoute => length > 1 ? elementAt(1) : null;

  String get currentUrl => currentRoute.effectivePath;

  bool get hasPreviousRoute => previousRoute != null;

  History();

  void add(NavigatedRoute activatedRoute) {
    if (activatedRoute.effectivePath != currentRoute.effectivePath) {
      _history.insert(0, activatedRoute);
    }
  }

  // removes history from the current route to the [activatedRoute] included.
  void removeThrough(NavigatedRoute? activatedRoute) {
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
  Iterator<NavigatedRoute> get iterator => _history.iterator;
}
