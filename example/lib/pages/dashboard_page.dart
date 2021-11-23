import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content of the example:',
                style: Theme.of(context).textTheme.headline5,
              ),
              const Text(
                  '- Authentication resolver: When logging we are redirected'),
              const Text('- Tabs change url, urls change tabs'),
              const Text('- Passing parameters in product details page'),
              const Text('- When route is not found we are redirected to home'),
              const Text('- Redirection of home route towards /dashboard'),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () => AuthService.instance.signOut(),
                  child: const Text(
                    'Sing out',
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
