import 'package:flutter/cupertino.dart';

import '../../x_router.dart';

mixin XResolver<T> {
  /// resolve a route with the current state
  String resolve(String target, List<XRoute> routes);
}
