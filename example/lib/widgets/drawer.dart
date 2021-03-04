import 'package:example/router.dart';
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
          )
        ],
      ),
    );
  }
}
