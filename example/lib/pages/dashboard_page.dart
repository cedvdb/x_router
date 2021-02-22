import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard page'),
      ),
      body: Center(
        child: Text('pretty graphs'),
      ),
    );
  }
}
