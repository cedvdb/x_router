import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<MaterialPage> _pageStack = [];

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
        activatedRoute.parameters,
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

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }
}
