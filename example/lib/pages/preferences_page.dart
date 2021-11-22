import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            XRouter.back();
          },
        ),
        title: Text('preferences'),
      ),
    );
  }
}
