import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccess(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> getAccess() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> deleteAccess() async {
    await _storage.delete(key: 'access_token');
  }

  Future<void> saveRefresh(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefresh() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefresh() async {
    await _storage.delete(key: 'refresh_token');
  }
}
