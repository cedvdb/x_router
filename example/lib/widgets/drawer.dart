import 'package:example/router/routes.dart';
import 'package:example/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:x_router/x_router.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Text('Dashboard'),
            onTap: () => XRouter.goTo(AppRoutes.dashboard),
          ),
          ListTile(
            title: Text('Products'),
            onTap: () => XRouter.goTo(AppRoutes.products),
          ),
          ListTile(
            title: Text('Sign  out'),
            onTap: () => AuthService.instance.signOut(),
          ),
        ],
      ),
    );
  }
}
