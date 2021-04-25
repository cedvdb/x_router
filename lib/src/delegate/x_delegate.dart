import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';

final GlobalKey<NavigatorState> _nestedNavigatorKey =
    GlobalKey<NavigatorState>();

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  GlobalKey<NavigatorState> get navigatorKey =>
      isRoot ? GlobalKey<NavigatorState>() : _nestedNavigatorKey;

  /// maintains the url
  @override
  String? currentConfiguration;

  /// callback called when the os receive a new route
  final Function(String) onNewRoute;
  final Function onDispose;

  /// the routes that we need to display
  XActivatedRoute _activatedRoute = XActivatedRoute(
    matchingRoute: XSpecialRoutes.initializationRoute,
    path: '',
    effectivePath: '',
  );

  /// whether this is the root delegate
  final bool isRoot;

  XRouterDelegate({
    required this.onNewRoute,
    required this.isRoot,
    required this.onDispose,
  });

  initBuild(XActivatedRoute activatedRoute) {
    _activatedRoute = activatedRoute;
    if (isRoot) {
      currentConfiguration = _activatedRoute.path;
    }
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
        _goUp();
        return route.didPop(res);
      },
      key: navigatorKey,
    );
  }

  MaterialPage _buildPage(
      BuildContext context, XActivatedRoute activatedRoute) {
    final builder = activatedRoute.matchingRoute.builder;
    return MaterialPage(child: builder(context, activatedRoute.parameters));
  }

  _goUp() {
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
