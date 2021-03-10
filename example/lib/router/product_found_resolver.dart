import 'package:example/router/routes.dart';
import 'package:example/services/products_service.dart';
import 'package:x_router/x_router.dart';

final productFoundResolver = XSimpleResolver((target, __) {
  final parse = XRouteParser(AppRoutes.productDetail).parse(target);
  final productFound = ProductsService.products.firstWhere(
    (p) => (p.id == parse.parameters['id']),
    orElse: () => null,
  );
  if (productFound != null) {
    return target;
  }
  return AppRoutes.products;
});
