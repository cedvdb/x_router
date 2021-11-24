import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/route/x_page_builder.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  /// maintains the url
  @override
  String? currentConfiguration;

  /// callback called when the os receive a new route
  final Function(String) onNewRoute;

  /// the routes that we need to display
  XActivatedRoute _activatedRoute = XActivatedRoute.nulled();

  XRouterDelegate({
    required this.onNewRoute,
  });

  initRendering(XActivatedRoute activatedRoute) {
    currentConfiguration = activatedRoute.effectivePath;
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

  void _setBrowserTitle(BuildContext context) {
    final titleBuilder = _activatedRoute.route.titleBuilder;
    if (kIsWeb && titleBuilder != null) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: titleBuilder(context, _activatedRoute),
          primaryColor: Theme.of(context).primaryColor.value,
        ),
      );
    }
  }

  pop() {
    if (_activatedRoute.upstack.isNotEmpty) {
      setNewRoutePath(_activatedRoute.upstack.last.effectivePath);
    }
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    onNewRoute(configuration);
    return SynchronousFuture(null);
  }
}
