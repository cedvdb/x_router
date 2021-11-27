import 'dart:async';

import 'package:example/main.dart';
import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/favorites_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class HomeLayout extends StatefulWidget {
  final String appBarTitle;

  const HomeLayout({
    Key? key,
    required this.appBarTitle,
  }) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription? navSubscription;

  final _tabsIndex = <String, int>{
    RouteLocations.dashboard: 0,
    RouteLocations.products: 1,
    RouteLocations.favorites: 2,
  };

  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _findTabIndex(router.history.currentUrl) ?? 0,
    );
    navSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .cast<NavigationEnd>()
        .listen((nav) => _refreshTabIndex);
    super.initState();
  }

  @override
  void dispose() {
    navSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// changes the selected tab when the url changes
  _refreshTabIndex() {
    final foundIndex = _findTabIndex(router.history.currentUrl);
    if (foundIndex != null) {
      _tabController.animateTo(foundIndex);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        actions: [
          IconButton(
            onPressed: () => router.goTo(RouteLocations.preferences),
            icon: const Icon(Icons.settings),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => _navigate(index),
          tabs: const [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.star)),
            Tab(icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DashboardPage(),
          ProductsPage(),
          const FavoritesPage(),
        ],
      ),
    );
  }
}
