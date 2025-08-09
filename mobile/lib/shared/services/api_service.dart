// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'secure_storage_service.dart';

/// Service for making authenticated HTTP requests to the backend API.
/// Handles token management, refresh, and automatic logout on failure.
class ApiService {
  /// Service for secure storage of tokens.
  final _storage = SecureStorageService();

  /// Base URL for API requests, loaded from environment or defaults to localhost.
  final String _baseUrl =
      dotenv.env['API_BASE'] ?? "http://10.0.2.2:3000/api/v1";

  /// Sends a GET request to the given endpoint.
  Future<http.Response> get(String endpoint, {BuildContext? context}) async {
    return _sendRequest('GET', endpoint, context: context);
  }

  /// Sends a POST request with a JSON body to the given endpoint.
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    BuildContext? context,
  }) async {
    return _sendRequest('POST', endpoint, body: body, context: context);
  }

  /// Sends a PATCH request with a JSON body to the given endpoint.
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    BuildContext? context,
  }) async {
    return _sendRequest('PATCH', endpoint, body: body, context: context);
  }

  /// Sends a DELETE request to the given endpoint.
  Future<http.Response> delete(String endpoint, {BuildContext? context}) async {
    return _sendRequest('DELETE', endpoint, context: context);
  }

  /// Internal method to send HTTP requests with authentication and handle token refresh.
  /// If a 401 is received, tries to refresh the token and retry once. Logs out if refresh fails.
  Future<http.Response> _sendRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    BuildContext? context,
  }) async {
    String? token = await _storage.getAccess();
    final uri = Uri.parse('$_baseUrl/$endpoint');

    http.Response response = await _makeHttpCall(method, uri, token, body);

    if (response.statusCode == 401) {
      // Try to refresh token once
      bool refreshed = await _refreshToken();
      if (!refreshed) {
        await _logoutAndRedirect(context);
        return response;
      }

      // Retry with new token
      token = await _storage.getAccess();
      response = await _makeHttpCall(method, uri, token, body);

      if (response.statusCode == 401) {
        await _logoutAndRedirect(context);
      }
    }

    return response;
  }

  /// Helper to make the actual HTTP call with the given method, URI, token, and body.
  Future<http.Response> _makeHttpCall(
    String method,
    Uri uri,
    String? token,
    Map<String, dynamic>? body,
  ) async {
    final headers = {
      'Authorization': token != null ? 'Bearer $token' : '',
      'Content-Type': 'application/json',
    };

    switch (method) {
      case 'GET':
        return await http.get(uri, headers: headers);
      case 'POST':
        return await http.post(uri, headers: headers, body: jsonEncode(body));
      case 'PATCH':
        return await http.patch(uri, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return await http.delete(uri, headers: headers);
      default:
        throw Exception('Método HTTP no soportado: $method');
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if successful, false otherwise.
  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.getRefresh();
    print(refreshToken);
    if (refreshToken == null) return false;

    final uri = Uri.parse('$_baseUrl/auth/refresh');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      await _storage.saveAccess(data['accessToken']);
      await _storage.saveRefresh(data['refreshToken']);
      return true;
    }

    return false;
  }

  /// Logs out the user by deleting tokens and redirects to the auth screen if context is available.
  Future<void> _logoutAndRedirect(BuildContext? context) async {
    await _storage.deleteAccess();
    await _storage.deleteRefresh();
    if (context != null && context.mounted) {
      context.go('/auth'); // Redirects using go_router
    }
  }
}
