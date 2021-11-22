import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product? product;
  ProductDetailsPage(String id) : product = ProductsService.getById(id);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('product details (Nested routing)')),
      body: Center(
        child: Card(
          child: widget.product != null
              ? Text(widget.product!.name)
              : Text('unknwon product'),
        ),
      ),
    );
  }
}
