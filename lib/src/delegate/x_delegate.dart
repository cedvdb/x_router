import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';

class XRouterDelegate extends RouterDelegate<String> with ChangeNotifier {
  @override
  late GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String? get currentConfiguration {
    if (_isRoot) {
      return _activatedRoute.effectivePath;
    }
    return null;
  }

  /// callback called when the os receive a new route
  final Function(String) onNewRoute;

  /// the routes that we need to display
  XActivatedRoute _activatedRoute = XActivatedRoute.nulled();

  /// child router do not need to report when a new route has been
  /// reached only the top router
  final bool _isRoot;

  XRouterDelegate({
    required this.onNewRoute,
    bool isRoot = true,
  }) : _isRoot = isRoot;

  void render(XActivatedRoute activatedRoute) {
    _activatedRoute = activatedRoute;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // upstack
      ..._activatedRoute.upstack.map((r) => _buildPage(context, r)),
      // top
      _buildPage(context, _activatedRoute)
    ];
    _setBrowserTitle(context);
    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, res) {
        // pop();
        route.didPop(res);
        return false;
      },
    );
  }

  Page _buildPage(
    BuildContext context,
    XActivatedRoute activatedRoute,
  ) {
    final route = activatedRoute.route;
    final child = route.builder(context, activatedRoute);
    return MaterialPage(
      key: route.pageKey,
      child: child,
    );
  }

  void _setBrowserTitle(BuildContext context) {
    final titleBuilder = _activatedRoute.route.titleBuilder;
    if (kIsWeb && titleBuilder != null) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: titleBuilder(context),
          primaryColor: Theme.of(context).primaryColor.value,
        ),
      );
    }
  }

  @override
  Future<bool> popRoute() async {
    print('navigatorKey: $navigatorKey');
    final NavigatorState? navigator = navigatorKey?.currentState;
    if (navigator == null) {
      return SynchronousFuture<bool>(false);
    }
    navigator.pop();
    return false;
  }

  pop() {
    if (_activatedRoute.upstack.isNotEmpty) {
      setNewRoutePath(_activatedRoute.upstack.last.matchingPath);
    }
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    onNewRoute(configuration);
    return SynchronousFuture(null);
  }
}
