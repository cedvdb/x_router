import 'package:example/services/products_service.dart';
import 'package:example/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:x_router/x_router.dart';

final xRouter = XRouter.child(
  routes: [
    XRoute(path: '/products/:id/info', builder: (_, __) => ProductInfo()),
    XRoute(
      path: '/products/:id/comments',
      builder: (_, __) => ProductComments(),
    ),
  ],
);

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  ProductDetailsPage(String id) : product = ProductsService.getById(id);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('product details (Nested routing)')),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Text(widget.product.name),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () => XRouter.goTo('./comments'),
                  child: Text('comments')),
              ElevatedButton(
                  onPressed: () => XRouter.goTo('./info'), child: Text('info')),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Router(
                  routerDelegate: xRouter.delegate,
                ),
              ),
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
      child: Text('comments (in nested router)'),
    );
  }
}

class ProductInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('info (in nested router)'),
    );
  }
}
