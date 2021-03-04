import 'package:example/router/routes.dart';
import 'package:example/services/products_service.dart';
import 'package:example/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class ProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('products page'),
      ),
      drawer: AppDrawer(),
      body: ListView(
        children: [
          for (var product in ProductsService.products)
            ListTile(
              title: Text(product.name),
              subtitle: Text('\$ ' + product.price.toString()),
              onTap: () => XRouter.goTo(AppRoutes.productDetail,
                  params: {'id': product.id}),
            )
        ],
      ),
    );
  }
}
