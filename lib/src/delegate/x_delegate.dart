import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_router/src/navigated_route/x_navigated_route.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String? get currentConfiguration {
    if (_navigatedRoute.child == null) return _navigatedRoute.effectivePath;
    return null;
  }

  final void Function(String) onNewPath;

  /// the routes that we need to display
  XNavigatedRoute _navigatedRoute = XNavigatedRoute.nulled();

  final String? debugLabel;

  XRouterDelegate({
    required this.onNewPath,
    this.debugLabel,
  });

  void render(XNavigatedRoute activatedRoute) {
    _navigatedRoute = activatedRoute;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // poppableStack
      ..._navigatedRoute.poppableStack.map((r) => _buildPage(context, r)),
      // top
      _buildPage(context, _navigatedRoute)
    ];
    _setBrowserTitle(context);
    final navigator = _buildNavigator(pages);
    if (Router.of(context).backButtonDispatcher != null) {
      _wrapWithBackButtonListener(navigator);
    }
    return navigator;
  }

  Page _buildPage(
    BuildContext context,
    XNavigatedRoute activatedRoute,
  ) {
    final route = activatedRoute.route;
    final child = route.builder(context, activatedRoute);
    return MaterialPage(
      key: route.pageKey,
      child: child,
    );
  }

  Navigator _buildNavigator(List<Page> pages) => Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, res) {
          pop();
          // route.didPop(res);
          return false;
        },
      );

  Widget _wrapWithBackButtonListener(Navigator navigator) => BackButtonListener(
        onBackButtonPressed: () {
          if (_navigatedRoute.poppableStack.isEmpty) {
            popRoute();
          } else {
            pop();
          }
          return SynchronousFuture(false);
        },
        child: navigator,
      );

  void _setBrowserTitle(BuildContext context) {
    final titleBuilder = _navigatedRoute.route.titleBuilder;
    if (kIsWeb && titleBuilder != null) {
      SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
          label: titleBuilder(context),
          primaryColor: Theme.of(context).primaryColor.value,
        ),
      );
    }
  }

  pop() {
    if (_navigatedRoute.poppableStack.isNotEmpty) {
      setNewRoutePath(_navigatedRoute.poppableStack.last.matchingPath);
    }
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    onNewPath(configuration);
    return SynchronousFuture(null);
  }
}
