import 'package:flutter/cupertino.dart';

abstract class XRouteResolver<T> extends ValueNotifier<T> {
  T get state => value;
  set state(T state) => value = state;

  XRouteResolver(T initialState) : super(initialState);

  /// resolve a route with the current state
  String resolve(String target);

  @override
  String toString() => '$runtimeType( $value )';
}
