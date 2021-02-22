import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('loading page'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
