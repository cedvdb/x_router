import 'package:example/main.dart';
import 'package:flutter/material.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            router.history.hasPreviousRoute
                ? router.back()
                : router.goTo(RouteLocations.dashboard);
          },
        ),
        title: const Text('preferences'),
      ),
      body: const Center(child: Text('preferences')),
    );
  }
}
