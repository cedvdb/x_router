import 'package:flutter/cupertino.dart';

mixin XResolver<T> {
  /// resolve a route with the current state
  Future<String> resolve(String target);
}
