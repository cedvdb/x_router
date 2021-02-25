import 'package:flutter/material.dart';

class NewDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  // TODO: implement navigatorKey
  GlobalKey<NavigatorState> get navigatorKey => throw UnimplementedError();

  @override
  Future<void> setNewRoutePath(String configuration) {
    // TODO: implement setNewRoutePath
    throw UnimplementedError();
  }
}
