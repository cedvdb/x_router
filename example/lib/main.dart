import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';
import 'pages/dashboard_page.dart';

final router = XRouter(routes: [
  XRoute(path: '/', redirect: (target) => '/dashboard'),
  XRoute(path: '/dashboard', builder: (ctx, params) => DashboardPage())
]);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.parser,
      routerDelegate: router.delegate,
      title: 'XRouter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
