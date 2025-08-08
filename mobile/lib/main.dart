import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mi App',
      routerConfig: appRouter, // Aquí usamos nuestro GoRouter
    );
  }
}
