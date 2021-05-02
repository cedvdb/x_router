import 'package:example/router/routes.dart';
import 'package:example/services/products_service.dart';
import 'package:x_router/x_router.dart';

final productFoundResolver = XSimpleResolver((target) async {
  final parse = XRouteParser(AppRoutes.productDetail).parse(target);
  try {
    ProductsService.products.firstWhere(
      (p) => (p.id == parse.parameters['id']),
    );
    return target;
  } catch (e) {
    return AppRoutes.products;
  }
});
