import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_special_routes.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  /// maintains the url
  String? currentConfiguration;

  /// callback called when the os receive a new route
  final Function(String) onNewRoute;

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
    return Navigator(
      pages: [
        // parents
        ..._activatedRoute.upstack.map((r) => _buildPage(context, r)),
        // top
        _buildPage(context, _activatedRoute)
      ],
      onPopPage: (route, res) {
        _goUp();
        return route.didPop(res);
      },
    );
  }

  _buildPage(BuildContext context, XActivatedRoute activatedRoute) {
    final builder = activatedRoute.matchingRoute.builder;
    return MaterialPage(child: builder(context, activatedRoute.parameters));
  }

  _goUp() {
    if (_activatedRoute.upstack.length > 1) {
      setNewRoutePath(_activatedRoute.upstack.last.effectivePath);
    }
  }

  @override
  Future<void> setNewRoutePath(String target) {
    onNewRoute(target);
    return SynchronousFuture(null);
  }
}
