import 'dart:async';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  StreamSubscription? navSubscription;

  final _tabsIndex = <String, int>{
    RouteLocations.dashboard: 0,
    RouteLocations.products: 1,
    RouteLocations.favorites: 2,
  };

  @override
  void initState() {
    _selectedTab = _findTabIndex(router.history.currentUrl) ?? 0;
    navSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .cast<NavigationEnd>()
        .listen((nav) => _refreshBottomBar);
    super.initState();
  }

  @override
  void dispose() {
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
    setState(() => _selectedTab = index);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(router.history.currentUrl),
        actions: [
          IconButton(
            onPressed: () => router.goTo(RouteLocations.preferences),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _navigate,
        selectedIndex: _selectedTab,
        destinations: const [
          // material you
          NavigationDestination(label: 'dashboard', icon: Icon(Icons.home)),
          NavigationDestination(
              label: 'products', icon: Icon(Icons.shopping_bag)),
          NavigationDestination(label: 'favorites', icon: Icon(Icons.favorite))
        ],
      ),
      body: Router(
          routerDelegate:
              router.childRouterStore.findDelegate(RouteLocations.home)),
    );
  }
}
