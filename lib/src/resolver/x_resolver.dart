import 'package:flutter/cupertino.dart';

abstract class RouteResolver<T> extends ValueNotifier<T> {
  T get state => value;

  RouteResolver(T initialState) : super(initialState);

  /// resolve a route with the current state
  Future<String> resolve(String target);

  @override
  String toString() => '$runtimeType( $value )';
}
