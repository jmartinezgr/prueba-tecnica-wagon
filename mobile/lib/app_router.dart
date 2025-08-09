import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/register_screen.dart';

import 'features/auth/presentation/auth_landing_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'splash_screen.dart';

/// The main router for the app, sets up all available routes and initial location.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', // App starts at splash screen
  routes: [
    /// Redirect root path to splash
    GoRoute(path: '/', redirect: (context, state) => '/splash'),

    /// Splash screen route
    GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),

    /// Authentication landing (choose login/register)
    GoRoute(path: '/auth', builder: (context, state) => AuthLandingScreen()),

    /// Login screen route
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),

    /// Register screen route
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),

    /// Home screen route (main app content)
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
  ],
);
