import 'package:example/pages/home_layout.dart';
import 'package:example/widgets/drawer.dart';
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
              Text(
                  '- Authentication resolver: When logging out via the drawer we are redirected'),
              Text('- Child / nested router in products details page'),
              Text('- Passing parameters in product details page'),
              Text('- When route is not found we are redirected to home'),
              Text('- Redirection of home route towards /dashboard'),
            ],
          ),
        ),
      ),
    );
  }
}
