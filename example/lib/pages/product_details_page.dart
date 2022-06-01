import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  ProductDetailsPage(String id, {super.key})
      : product = ProductsService.getById(id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Center(child: Text('Product: ${product.name}')),
    );
  }
}
