import 'dart:async';

import 'package:example/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class HomeLayout extends StatefulWidget {
  final Widget child;
  final String title;
  const HomeLayout({
    required this.child,
    required this.title,
  }) : super(key: const ValueKey('HomeLayout'));

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StreamSubscription? navSubscription;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        XRouter.goTo(AppRoutes.dashboard);
      } else {
        XRouter.goTo(AppRoutes.products);
      }
    });
    navSubscription = XRouter.navigationEndStream.listen((event) {
      if (event.target.startsWith(AppRoutes.dashboard)) {
        _tabController.animateTo(0);
      } else if (event.target.startsWith(AppRoutes.products)) {
        _tabController.animateTo(1);
      } else {
        _tabController.animateTo(2);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    navSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.star)),
            Tab(icon: Icon(Icons.favorite)),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}
