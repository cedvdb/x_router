import 'dart:async';

import 'package:example/main.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:x_router/x_router.dart';

class ProductRouteLocations {
  static const info = '${RouteLocations.productDetail}/info';
  static const comments = '${RouteLocations.productDetail}/comments';
}

class ProductDetailsPage extends StatefulWidget {
  final Product? product;
  static final productRouter = XChildRouter(
    basePath: RouteLocations.products,
    routes: [
      XRoute(
        path: ProductRouteLocations.info,
        builder: (_, __) =>
            const Center(child: Text('info (Displayed via nested router)')),
      ),
      XRoute(
        path: ProductRouteLocations.comments,
        builder: (_, __) =>
            const Center(child: Text('comments (displayed via nested router)')),
      ),
    ],
  );
  ProductDetailsPage(String id) : product = ProductsService.getById(id);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  StreamSubscription _routerSubscription;

  @override
  initState() {
    _tabController = TabController(length: 2, vsync: this);
    _routerSubscription = router.eventStream
        .where((event) => event is NavigationEnd)
        .cast<NavigationEnd>()
        .listen((event) {
          if ()
        });
    super.initState();
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
      body: Router(routerDelegate: ProductDetailsPage.productRouter.delegate),
    );
  }
}
