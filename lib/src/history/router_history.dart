import 'package:x_router/src/activated_route/x_activated_route.dart';

// responsible of keeping track of the history

class XRouterHistory {
  final List<XActivatedRoute> _history = [];

  XActivatedRoute? get currentRoute => _history.last;
  XActivatedRoute? get previousRoute =>
      length > 1 ? _history.elementAt(_history.length - 2) : null;

  bool get hasPreviousRoute => previousRoute != null;
  int get length => _history.length;

  XRouterHistory();

  add(XActivatedRoute activatedRoute) {
    if (activatedRoute.effectivePath != currentRoute?.effectivePath) {
      _history.add(activatedRoute);
    }
  }

  replaceLast(XActivatedRoute activatedRoute) {
    _history[_history.length - 1] = activatedRoute;
  }

  removeLast() {
    _history.removeLast();
  }
}
