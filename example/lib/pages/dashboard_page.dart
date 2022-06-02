import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'This page is displayed inside a child router',
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'The products page shows a stack of pages inside a child router',
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Sign out automatically redirects to auth page thanks to reactive resolvers',
            ),
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
