import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  final storage = const FlutterSecureStorage();

  Future<void> _login(BuildContext context) async {
    // Simulación: guardamos un token
    await storage.write(key: 'auth_token', value: 'fake_token');
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _login(context),
          child: const Text('Iniciar sesión'),
        ),
      ),
    );
  }
}
