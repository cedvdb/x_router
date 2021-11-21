import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_route.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  /// maintains the url
  @override
  String? currentConfiguration;

  /// callback called when the os receive a new route
  final Function(String) onNewRoute;
  final Function onDispose;

  /// the routes that we need to display
  XActivatedRoute _activatedRoute = XActivatedRoute(
    route: XRoute(
      path: '',
      builder: (ctx, params) => Container(),
    ),
    path: '',
    effectivePath: '',
  );

  XRouterDelegate({
    required this.onNewRoute,
    required this.onDispose,
  });

  initBuild(XActivatedRoute activatedRoute) {
    _activatedRoute = activatedRoute;
    currentConfiguration = _activatedRoute.path;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // parents
      ..._activatedRoute.upstack.map((r) => _buildPage(context, r)),
      // top
      _buildPage(context, _activatedRoute)
    ];

    return Navigator(
      pages: pages,
      onPopPage: (route, res) {
        pop();
        return route.didPop(res);
      },
      key: navigatorKey,
    );
  }

  MaterialPage _buildPage(
    BuildContext context,
    XActivatedRoute activatedRoute,
  ) {
    final builder = activatedRoute.route.builder;
    return MaterialPage(child: builder(context, activatedRoute.parameters));
  }

  pop() {
    if (_activatedRoute.upstack.length >= 1) {
      setNewRoutePath(_activatedRoute.upstack.last.effectivePath);
    }
  }

  @override
  Future<void> setNewRoutePath(String target) {
    onNewRoute(target);
    return SynchronousFuture(null);
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }
}
