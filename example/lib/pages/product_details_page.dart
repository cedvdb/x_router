import 'dart:async';

import 'package:example/main.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product? product;

  ProductDetailsPage(String id) : product = ProductsService.getById(id);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  StreamSubscription? _routerSubscription;

  final Map<String, int> _tabIndexes = const {
    RouteLocations.productInfo: 0,
    RouteLocations.productComments: 1,
  };

  @override
  initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _findTabIndex(router.history.currentUrl) ?? 0,
    );
    _routerSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .listen((_) => _changeTabIndex(router.history.currentUrl));
    super.initState();
  }

  @override
  dispose() {
    _routerSubscription?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  /// changes tab index given a path
  _changeTabIndex(String path) {
    final index = _findTabIndex(path);
    if (index != null && index != _tabController?.index) {
      _tabController?.animateTo(index);
    }
  }

  /// finds the tab index given a path
  int? _findTabIndex(String path) {
    try {
      return _tabIndexes.entries
          .firstWhere((entry) => path.startsWith(entry.key))
          .value;
    } catch (e) {
      return null;
    }
  }

  _navigate(int index) {
    if (index == 0) {
      router.goTo('./info');
    } else if (index == 1) {
      router.goTo('./comments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          onTap: _navigate,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
            ),
            Tab(
              icon: Icon(Icons.comment),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProductViewItem(title: 'info'),
          ProductViewItem(title: 'comments'),
        ],
      ),
    );
  }
}

class ProductViewItem extends StatelessWidget {
  final String title;
  const ProductViewItem({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Tabs change url',
          style: Theme.of(context).textTheme.headline4,
        ),
        const SizedBox(
          height: 20,
        ),
        Text(title)
      ],
    );
  }
}
