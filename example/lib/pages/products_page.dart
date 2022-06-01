import 'package:example/main.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('products'),
      ),
      body: ListView(
        children: [
          for (var product in ProductsService.products)
            ListTile(
              title: Text(product.name),
              subtitle: Text('\$ ${product.price}'),
              onTap: () => router.goTo(RouteLocations.productDetail,
                  params: {'id': product.id}),
            )
        ],
      ),
    );
  }
}
