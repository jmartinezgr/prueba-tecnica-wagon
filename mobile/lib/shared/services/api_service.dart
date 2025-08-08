import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

//TODO : Implementar métodos para manejar errores de token para evaluar refrescarlos y sino redirigir al login
class ApiService {
  final _storage = SecureStorageService();

  Future<http.Response> get(String endpoint) async {
    final token = await _storage.getAccess();
    final uri = Uri.parse('http://10.0.2.2:3000/api/v1/$endpoint');

    return await http.get(
      uri,
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _storage.getAccess();
    final uri = Uri.parse('http://10.0.2.2:3000/api/v1/$endpoint');

    return await http.post(
      uri,
      headers: {
        'Authorization': token != null ? 'Bearer $token' : '',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }
}
