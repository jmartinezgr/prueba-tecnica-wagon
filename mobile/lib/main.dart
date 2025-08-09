/// Entry point for the Flutter app. Loads environment variables and runs the app.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_router.dart';

/// Main function initializes Flutter bindings and loads .env variables.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

/// Root widget for the app, sets up routing and app title.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mi App',
      routerConfig: appRouter, // Uses GoRouter for navigation
    );
  }
}
