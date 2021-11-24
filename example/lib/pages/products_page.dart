import 'package:example/main.dart';
import 'package:example/services/products_service.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          for (var product in ProductsService.products)
            ListTile(
              title: Text(product.name),
              subtitle: Text('\$ ' + product.price.toString()),
              onTap: () => router.goTo(RouteLocations.productDetail,
                  params: {'id': product.id}),
            )
        ],
      ),
    );
  }
}
