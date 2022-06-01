import 'dart:async';

import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

import '../main.dart';

class NavRail extends StatefulWidget {
  const NavRail({
    Key? key,
  }) : super(key: key);

  @override
  State<NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<NavRail> {
  final _tabsIndex = <XRoutePattern, int>{
    XRoutePattern(RouteLocations.dashboard): 0,
    XRoutePattern(RouteLocations.products): 1,
    XRoutePattern(RouteLocations.favorites): 2,
  };
  StreamSubscription? navSubscription;

  int _selectedTab = 0;

  @override
  void initState() {
    _selectedTab = _findTabIndex(router.history.currentUrl) ?? 0;
    navSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .listen((nav) => _refreshBottomBar());
    super.initState();
  }

  @override
  dispose() {
    navSubscription?.cancel();
    super.dispose();
  }

  /// changes the selected tab when the url changes
  _refreshBottomBar() {
    final foundIndex = _findTabIndex(router.history.currentUrl);
    if (foundIndex != null) {
      setState(() => _selectedTab = foundIndex);
    }
  }

  /// finds the tab index associated with a path
  int? _findTabIndex(String path) {
    for (final pattern in _tabsIndex.keys) {
      if (pattern.match(path, matchChildren: true)) {
        return _tabsIndex[pattern];
      }
    }
    return null;
  }

  /// when a tab is clicked, navigate to the target location
  _navigate(int index) {
    router.goTo(_findRoutePath(index));
  }

  /// finds the url path given a tab index
  String _findRoutePath(int index) {
    for (final entry in _tabsIndex.entries) {
      if (entry.value == index) {
        return entry.key.path;
      }
    }
    return _tabsIndex.keys.first.path;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      onDestinationSelected: _navigate,
      selectedIndex: _selectedTab,
      extended: true,
      destinations: const [
        // material you
        NavigationRailDestination(
            label: Text('dashboard'), icon: Icon(Icons.home)),
        NavigationRailDestination(
            label: Text('products'), icon: Icon(Icons.shopping_bag)),
        NavigationRailDestination(
            label: Text('favorites'), icon: Icon(Icons.favorite))
      ],
    );
  }
}
