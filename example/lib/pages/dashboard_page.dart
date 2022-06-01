import 'package:example/main.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dashboard'),
        actions: [
          IconButton(
              onPressed: () => router.goTo(RouteLocations.account),
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Tabs navigation',
              style: Theme.of(context).textTheme.headline5,
            ),
            const Text('- Tabs change url'),
            const Text('- Animation is not stopped'),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => AuthService.instance.signOut(),
              child: const Text(
                'Sing out',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
