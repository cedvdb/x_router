import 'package:example/widgets/drawer.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard page'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
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
    );
  }
}
