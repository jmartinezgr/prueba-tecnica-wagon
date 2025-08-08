import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';

class SplashScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      final secureStorageService = SecureStorageService();
      final accessToken = await secureStorageService.getAccess();
      final refreshToken = await secureStorageService.getRefresh();
      print('Access Token: $accessToken');
      print('Refresh Token: $refreshToken');

      if (accessToken != null && refreshToken != null) {
        ApiService apiService = ApiService();
        final response = await apiService.get('auth/profile');

        if (response.statusCode == 200) {
          print(response.body);
          context.go('/home');
        } else {
          context.go('/login');
        }
      } else {
        context.go('/login');
      }
    });

    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
