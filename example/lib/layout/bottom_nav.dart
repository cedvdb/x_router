import 'dart:async';

import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

import '../main.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({
    Key? key,
  }) : super(key: const ValueKey('my-bottom-nav'));

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final _tabsIndex = <String, int>{
    RouteLocations.dashboard: 0,
    RouteLocations.products: 1,
    RouteLocations.favorites: 2,
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

  /// when a tab is clicked, navigate to the target location
  _navigate(int index) {
    router.goTo(_findRoutePath(index));
  }

  /// finds the tab index associated with a path
  int? _findTabIndex(String path) {
    try {
      return _tabsIndex.entries
          .firstWhere((entry) => path.startsWith(entry.key))
          .value;
    } catch (e) {
      return null;
    }
  }

  /// finds the url path given a tab index
  String _findRoutePath(int index) {
    return _tabsIndex.entries.firstWhere((entry) => entry.value == index).key;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: _navigate,
      selectedIndex: _selectedTab,
      key: const ValueKey('bottom-navigation-bar'),
      destinations: const [
        // material you
        NavigationDestination(label: 'dashboard', icon: Icon(Icons.home)),
        NavigationDestination(
            label: 'products', icon: Icon(Icons.shopping_bag)),
        NavigationDestination(label: 'favorites', icon: Icon(Icons.favorite))
      ],
    );
  }
}
