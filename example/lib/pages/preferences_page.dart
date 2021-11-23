import 'package:example/main.dart';
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
            XRouter.history.hasPreviousRoute
                ? XRouter.back()
                : XRouter.goTo(AppRoutes.dashboard);
          },
        ),
        title: Text('preferences'),
      ),
    );
  }
}
