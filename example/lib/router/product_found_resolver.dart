import 'package:example/router/routes.dart';
import 'package:example/services/products_service.dart';
import 'package:x_router/x_router.dart';

final productFoundResolver = XSimpleResolver((target) {
  final parse = XRoutePattern(AppRoutes.productDetail).parse(target);
  try {
    ProductsService.products.firstWhere(
      (p) => (p.id == parse.parameters['id']),
    );
    return Next();
  } catch (e) {
    return Redirect(target);
  }
});
