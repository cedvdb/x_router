import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../services/auth_service.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sign in page'),
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            child: Text('sign in'),
            onPressed: () => AuthService.instance.signIn(),
          ),
        ),
      ),
    );
  }
}
