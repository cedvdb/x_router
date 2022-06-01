import 'package:flutter/cupertino.dart';
import 'package:x_router/x_router.dart';

abstract class BaseRouter {
  List<XRoute> get routes;
  RouterDelegate get delegate;
  RouteInformationParser<String> get informationParser;
  RouteInformationProvider get informationProvider;
  BackButtonDispatcher get backButtonDispatcher;
}
