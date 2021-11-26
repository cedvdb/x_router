import 'dart:async';

import 'package:example/main.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    _tabController = TabController(length: 2, vsync: this);
    // _routerSubscription = router.eventStream
    //     .where((event) => event is NavigationEnd)
    //     .cast<NavigationEnd>()
    //     .listen((event) => _changeTabIndex(event.activatedRoute.requestedPath));
    super.initState();
  }

  @override
  dispose() {
    _routerSubscription?.cancel();
    super.dispose();
  }

  _changeTabIndex(String path) {
    final index = _findTabIndex(path);
    if (index != null && index != _tabController?.index) {
      _tabController?.animateTo(index);
    }
  }

  int? _findTabIndex(String path) {
    try {
      _tabIndexes.entries
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
    final delegate = router.childRouterStore.findDelegate(
      RouteLocations.productDetail,
    );

    print(delegate);
    return Scaffold(
      appBar: AppBar(
        title: Text('product details: ${widget.product!.name}'),
        bottom: TabBar(
          controller: _tabController,
          onTap: _navigate,
          tabs: const [
            Tab(
              icon: Icon(Icons.home),
            ),
            Tab(
              icon: Icon(Icons.favorite),
            ),
          ],
        ),
      ),
      body: Router(
        routerDelegate: router.childRouterStore.findDelegate(
          RouteLocations.productDetail,
        ),
      ),
    );
  }
}
