import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/history/router_history.dart';
import 'package:x_router/src/state/x_router_state.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  /// maintains the url
  @override
  String? currentConfiguration;

  /// callback called when the os receive a new route
  final Function(String) onNewRoute;


  XRouterDelegate({
    required this.onNewRoute,
  });

  initRendering(XActivatedRoute activatedRoute) {
    currentConfiguration = ;
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
    _setBrowserTitle(context, _activatedRoute.route.title);
    return Navigator(
      key: const ValueKey('root_navigator'),
      pages: pages,
      onPopPage: (route, res) {
        pop();
        return route.didPop(res);
      },
    );
  }

  MaterialPage _buildPage(
    BuildContext context,
    XActivatedRoute activatedRoute,
  ) {
    final route = activatedRoute.route;
    final builder = route.builder;
    return MaterialPage(
      key: route.pageKey,
      child: builder(
        context,
        activatedRoute,
      ),
      restorationId: route.pageKey.toString(),
    );
  }

  void _setBrowserTitle(BuildContext context, String? title) {
    if (kIsWeb && title != null) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: title,
          primaryColor: Theme.of(context).primaryColor.value,
        ),
      );
    }
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
}
