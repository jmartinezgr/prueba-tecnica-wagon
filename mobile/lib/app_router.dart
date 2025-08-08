import 'package:go_router/go_router.dart';

import 'features/auth/presentation/auth_landing_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'splash_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/auth', builder: (context, state) => AuthLandingScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
  ],
);
