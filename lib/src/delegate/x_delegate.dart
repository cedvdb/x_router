import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_router/src/activated_route/x_activated_route.dart';
import 'package:x_router/src/events/x_event_emitter.dart';
import 'package:x_router/src/events/x_router_events.dart';

class XRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  @override
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  String? get currentConfiguration {
    if (_isRoot) {
      return _activatedRoute.effectivePath;
    }
    return null;
  }

  final XEventEmitter _eventEmitter = XEventEmitter.instance;

  /// the routes that we need to display
  XActivatedRoute _activatedRoute = XActivatedRoute.nulled();

  /// child router do not need to report when a new route has been
  /// reached only the top router
  final bool _isRoot;

  XRouterDelegate({
    bool isRoot = true,
  }) : _isRoot = isRoot;

  void render(XActivatedRoute activatedRoute) {
    _activatedRoute = activatedRoute;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // downStack
      ..._activatedRoute.downStack.map((r) => _buildPage(context, r)),
      // top
      _buildPage(context, _activatedRoute)
    ];
    _setBrowserTitle(context);
    return BackButtonListener(
      onBackButtonPressed: () {
        if (_activatedRoute.downStack.isEmpty) {
          return SynchronousFuture(true);
        } else {
          pop();
          return SynchronousFuture(false);
        }
      },
      child: Navigator(
        key: navigatorKey,
        pages: pages,
        onPopPage: (route, res) {
          pop();
          route.didPop(res);
          return false;
        },
      ),
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

  pop() {
    if (_activatedRoute.downStack.isNotEmpty) {
      setNewRoutePath(_activatedRoute.downStack.last.matchingPath);
    }
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    _eventEmitter.emit(NavigationStart(target: configuration));
    return SynchronousFuture(null);
  }
}
