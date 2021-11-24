import 'dart:async';

import 'package:example/main.dart';
import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/favorites_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class HomeLayout extends StatefulWidget {
  final String title;
  const HomeLayout({
    Key? key,
    required this.title,
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

  int? _findTabIndex(String url) {
    try {
      return _tabsIndex.entries
          .firstWhere((entry) => url.startsWith(entry.key))
          .value;
    } catch (e) {
      return null;
    }
  }

  String _findUrlForTabIndex(int index) {
    return _tabsIndex.entries.firstWhere((entry) => entry.value == index).key;
  }

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
        .listen((nav) {
      final foundIndex = _findTabIndex(router.history.currentUrl);
      if (foundIndex != null) {
        _tabController.animateTo(foundIndex);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    navSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  _navigate(int index) {
    router.goTo(_findUrlForTabIndex(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
