import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/services/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final storage = const FlutterSecureStorage();
  final userInfoService = UserInfoService();

  LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    ApiService apiService = ApiService();
    SecureStorageService secureStorageService = SecureStorageService();
    const data = {'email': 'josemargri3@gmail.com', 'password': '++juanjose3M'};

    final response = await apiService.post('auth/login', data);

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      final accessToken = body['accessToken'];
      final refreshToken = body['refreshToken'];
      if (accessToken != null && refreshToken != null) {
        await secureStorageService.saveAccess(accessToken);
        await secureStorageService.saveRefresh(refreshToken);
        print(body['user']);
        await userInfoService.saveUser(body['user']);
        context.go('/home');
      } else {
        // Manejar caso sin token en respuesta
        _showError(context, 'Token no recibido');
      }
    } else {
      _showError(context, response.body.toString());
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
