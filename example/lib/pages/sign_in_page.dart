import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sign in page'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Reactive Resolvers',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('sign in to access the app'),
            ElevatedButton(
              child: const Text('sign in'),
              onPressed: () => AuthService.instance.signIn(),
            ),
          ],
        ),
      ),
    );
  }
}
