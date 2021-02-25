import 'package:flutter/cupertino.dart';
import 'package:state_notifier/state_notifier.dart';

abstract class XRouteResolver<T> extends ValueNotifier<T> {
  XRouteResolver(T initialState) : super(initialState);

  /// resolve a route with the current state
  String resolve(String target);

  @override
  String toString() => '$runtimeType( $value )';
}
