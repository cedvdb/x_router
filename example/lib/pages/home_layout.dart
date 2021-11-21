import 'dart:async';

import 'package:example/pages/dashboard_page.dart';
import 'package:example/pages/products_page.dart';
import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class HomeLayout extends StatefulWidget {
  final String title;
  final int index;
  const HomeLayout({
    Key? key,
    required this.title,
    required this.index,
  }) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription? navSubscription;

  @override
  void initState() {
    print('======> init state');
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.index,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _tabController.animateTo(widget.index);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
          ProductsPage(),
        ],
      ),
    );
  }
}
