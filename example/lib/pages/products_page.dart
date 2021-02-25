import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';

import '../router.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('products page'),
      ),
      body: ListView(
        children: [
          for (var product in ProductsService.products)
            ListTile(
              title: Text(product.name),
              subtitle: Text('\$ ' + product.price.toString()),
              onTap: () => router.goTo('/products/${product.id}'),
            )
        ],
      ),
    );
  }
}