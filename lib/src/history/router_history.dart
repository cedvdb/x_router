import 'package:x_router/src/activated_route/x_activated_route.dart';

// responsible of keeping track of the history

class XRouterHistory extends Iterable<XActivatedRoute> {
  final List<XActivatedRoute> _history = [];

  XActivatedRoute get currentRoute =>
      _history.isNotEmpty ? _history.last : XActivatedRoute.nulled();

  XActivatedRoute? get previousRoute =>
      length > 1 ? _history.elementAt(_history.length - 2) : null;

  bool get hasPreviousRoute => previousRoute != null;
  @override
  int get length => _history.length;

  XRouterHistory();

  add(XActivatedRoute activatedRoute) {
    if (activatedRoute.effectivePath != currentRoute.effectivePath) {
      _history.add(activatedRoute);
    }
  }

  removeFrom(XActivatedRoute? activatedRoute) {
    if (activatedRoute == null) return;
    for (final route in _history) {
      if (route == activatedRoute) {
        _history.removeLast();
        break;
      }
      _history.removeLast();
    }
  }

  @override
  Iterator<XActivatedRoute> get iterator => _history.iterator;
}
