import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  ProductDetailsPage(String id) : product = ProductsService.getById(id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('product details')),
      body: Column(
        children: [
          product != null ? Text(product.name) : Text('product not found'),
          // Router(routerDelegate: )
        ],
      ),
    );
  }
}
