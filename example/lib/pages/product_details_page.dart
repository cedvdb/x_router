import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  ProductDetailsPage(String id, {super.key})
      : product = ProductsService.getById(id);

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('close'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Column(
        children: [
          Center(child: Text('Product: ${product.name}')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _openDialog(context),
            child: const Text('open dialog'),
          )
        ],
      ),
    );
  }
}
