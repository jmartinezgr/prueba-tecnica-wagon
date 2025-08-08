import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      final token = await storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        context.go('/home'); // Token válido
      } else {
        context.go('/auth'); // Sin sesión
      }
    });

    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
