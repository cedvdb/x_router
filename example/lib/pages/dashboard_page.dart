import 'package:example/widgets/drawer.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard page'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text('pretty graphs'),
      ),
    );
  }
}
