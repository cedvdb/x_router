import 'package:example/services/products_service.dart';
import 'package:example/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:x_router/x_router.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  ProductDetailsPage(String id) : product = ProductsService.getById(id);
  final xRouter = XRouter.child(
    routes: [
      XRoute(path: '/products/:id/info', builder: (_, __) => ProductInfo()),
      XRoute(
          path: '/products/:id/comments',
          builder: (_, __) => ProductComments()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('product details')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          product != null ? Text(product.name) : Text('product not found'),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () => XRouter.goTo('/products/:id/comments'),
                  child: Text('comments')),
              ElevatedButton(
                  onPressed: () => XRouter.goTo('/products/:id/info'),
                  child: Text('info')),
            ],
          ),
          Expanded(
            child: Router(
              routerDelegate: xRouter.delegate,
            ),
          )
        ],
      ),
    );
  }
}

class ProductComments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('comments'),
    );
  }
}

class ProductInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('info'),
    );
  }
}
