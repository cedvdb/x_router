import 'package:flutter/cupertino.dart';

mixin XResolver<T> {
  /// resolve a route with the current state
  String resolve(String target);
}
