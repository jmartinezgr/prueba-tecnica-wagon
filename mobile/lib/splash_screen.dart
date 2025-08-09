// ignore_for_file: use_build_context_synchronously

/// SplashScreen handles initial app logic: checks authentication tokens and navigates accordingly.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/services/shared_preferences.dart';

/// Stateless widget that determines navigation based on authentication state.
class SplashScreen extends StatelessWidget {
  /// Secure storage instance for token management.
  final storage = FlutterSecureStorage();

  /// Service to store user info locally.
  final UserInfoService userInfoService = UserInfoService();

  /// Constructor for SplashScreen.
  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // On widget build, check for tokens and navigate to the correct screen.
    Future.delayed(Duration.zero, () async {
      final secureStorageService = SecureStorageService();
      final accessToken = await secureStorageService.getAccess();
      final refreshToken = await secureStorageService.getRefresh();

      if (accessToken != null && refreshToken != null) {
        // If tokens exist, validate them and fetch user profile.
        ApiService apiService = ApiService();
        final response = await apiService.get('auth/profile');

        if (response.statusCode == 200) {
          // If profile fetch is successful, save user and go to home.
          final user = jsonDecode(response.body);
          userInfoService.saveUser(user);
          context.go('/home');
        } else {
          // If token invalid, go to login.
          context.go('/login');
        }
      } else {
        // If no tokens, go to auth (onboarding/login).
        context.go('/auth');
      }
    });

    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
