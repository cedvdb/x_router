import 'package:flutter/cupertino.dart';

abstract class RouteResolver<T> extends ValueNotifier<T> {
  RouteResolver(T value) : super(value);

  String resolve(String target);

  @override
  String toString() => '$runtimeType($value)';
}
