import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'router/router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stack_trace/stack_trace.dart' as Trace;

void main() async {
  runApp(MyApp());
  // runZonedGuarded(() async {
  //   await Hive.initFlutter();
  // }, (e, st) {
  //   print(e);
  //   Trace.Trace.parse(st.toString());
  // });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.informationParser,
      routerDelegate: router.delegate,
      title: 'XRouter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
