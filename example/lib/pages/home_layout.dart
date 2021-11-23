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
    AppRoutes.dashboard: 0,
    AppRoutes.products: 1,
    AppRoutes.favorites: 2,
  };

  @override
  void initState() {
    print('======> init state');
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _tabsIndex[XRouter.history.currentRoute.effectivePath]!,
    );
    navSubscription = XRouter.eventStream
        .where((event) => event is NavigationEnd)
        .cast<NavigationEnd>()
        .listen((nav) {
      if (nav.target.startsWith(AppRoutes.products) &&
          _tabController.index != 1) {
        _tabController.animateTo(1);
      }
      if (nav.target.startsWith(AppRoutes.dashboard) &&
          _tabController.index != 0) {
        _tabController.animateTo(0);
      }
      if (nav.target.startsWith(AppRoutes.favorites) &&
          _tabController.index != 2) {
        _tabController.animateTo(2);
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _tabController.animateTo(widget.index);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    navSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  _navigate(int index) {
    if (index == 0) {
      XRouter.goTo(AppRoutes.dashboard);
    } else if (index == 1) {
      XRouter.goTo(AppRoutes.products);
    } else if (index == 2) {
      XRouter.goTo(AppRoutes.favorites);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => XRouter.goTo(AppRoutes.preferences),
            icon: Icon(Icons.settings),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => _navigate(index),
          tabs: [
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
          FavoritesPage(),
        ],
      ),
    );
  }
}
