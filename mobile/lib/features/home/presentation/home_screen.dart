import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final storage = const FlutterSecureStorage();

  Future<void> _logout(BuildContext context) async {
    await storage.delete(key: 'auth_token');
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: const Text('Cerrar sesión'),
        ),
      ),
    );
  }
}
