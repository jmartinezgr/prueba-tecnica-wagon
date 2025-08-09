/// Login screen for user authentication, handles login form, validation, and navigation.
library;
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/services/api_service.dart';
import 'package:mobile/shared/services/secure_storage_service.dart';
import 'package:mobile/shared/services/shared_preferences.dart';

/// Displays the login form and manages authentication logic.
class LoginScreen extends StatefulWidget {
  /// Creates a LoginScreen widget.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State for LoginScreen, manages form, authentication, and UI state.
class _LoginScreenState extends State<LoginScreen> {
  /// Key for the login form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email input field.
  final TextEditingController _emailController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController();

  /// Service for secure token storage.
  final SecureStorageService secureStorageService = SecureStorageService();

  /// Service for storing user info.
  final UserInfoService userInfoService = UserInfoService();

  /// Whether the login process is loading.
  bool _loading = false;

  /// Whether the password is obscured.
  bool _obscurePassword = true;

  /// Handles login logic: validates form, sends request, saves tokens, and navigates.
  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    ApiService apiService = ApiService();

    final data = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
    };
    try {
      final response = await apiService.post('auth/login', data);

      setState(() => _loading = false);

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final accessToken = body['accessToken'];
        final refreshToken = body['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await secureStorageService.saveAccess(accessToken);
          await secureStorageService.saveRefresh(refreshToken);
          await userInfoService.saveUser(body['user']);

          context.go('/home');
        } else {
          _showError(context, 'Token no recibido');
        }
      } else if (response.statusCode == 500) {
        _showError(context, "Ocurrio un error inesperado.");
      } else if (response.statusCode == 404) {
        _showError(
          context,
          "Ocurrion un error encontrando el servidor. Intenta de nuevo luego",
        );
      } else {
        final body = jsonDecode(response.body);

        if (body['message'] is List) {
          _showError(context, (body['message'] as List).join(', '));
        } else {
          _showError(context, body['message'] ?? 'Error desconocido');
        }
      }
    } on SocketException catch (_) {
      _showError(context, "Error de conexión");
    } on TimeoutException catch (_) {
      _showError(context, "La conexión ha expirado");
    } catch (_) {
      _showError(context, 'Ocurrió un error inesperado. Intenta nuevamente.');
    }
  }

  /// Shows an error message in a SnackBar.
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Main UI for login: form, validation, loading, and navigation.
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 5,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App icon/logo
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.login,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    const Text(
                      "Bienvenido de nuevo",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Inicia sesión en tu cuenta",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade600,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese su email'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey.shade600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue.shade600,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese su contraseña'
                          : null,
                    ),
                    const SizedBox(height: 30),
                    _loading
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade600,
                                  Colors.blue.shade500,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => _login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿No tienes una cuenta? "),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: const Text(
                            "Créala",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
