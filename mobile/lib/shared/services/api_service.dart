// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'secure_storage_service.dart';

class ApiService {
  final _storage = SecureStorageService();
  final String _baseUrl = 'http://10.0.2.2:3000/api/v1';

  Future<http.Response> get(String endpoint, {BuildContext? context}) async {
    return _sendRequest('GET', endpoint, context: context);
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    BuildContext? context,
  }) async {
    return _sendRequest('POST', endpoint, body: body, context: context);
  }

  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    BuildContext? context,
  }) async {
    return _sendRequest('PATCH', endpoint, body: body, context: context);
  }

  Future<http.Response> delete(String endpoint, {BuildContext? context}) async {
    return _sendRequest('DELETE', endpoint, context: context);
  }

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
      // Intentar refresh una sola vez
      bool refreshed = await _refreshToken();
      if (!refreshed) {
        await _logoutAndRedirect(context);
        return response;
      }

      // Intentar nuevamente con token renovado
      token = await _storage.getAccess();
      response = await _makeHttpCall(method, uri, token, body);

      if (response.statusCode == 401) {
        await _logoutAndRedirect(context);
      }
    }

    return response;
  }

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

  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.getRefresh();
    if (refreshToken == null) return false;

    final uri = Uri.parse('$_baseUrl/auth/refresh');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.saveAccess(data['accessToken']);
      return true;
    }

    return false;
  }

  Future<void> _logoutAndRedirect(BuildContext? context) async {
    await _storage.deleteAccess();
    await _storage.deleteRefresh();
    if (context != null && context.mounted) {
      context.go('/auth'); // Redirige con go_router
    }
  }
}
