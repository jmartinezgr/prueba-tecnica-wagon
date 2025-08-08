import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthLandingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                // Por ahora mandamos a login también
                context.go('/login');
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
