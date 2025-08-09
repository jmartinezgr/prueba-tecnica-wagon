/// Service for securely storing and retrieving authentication tokens using flutter_secure_storage.
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides methods to save, retrieve, and delete access and refresh tokens securely.
class SecureStorageService {
  /// Instance of FlutterSecureStorage for secure key-value storage.
  final _storage = const FlutterSecureStorage();

  /// Saves the access token securely.
  Future<void> saveAccess(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  /// Retrieves the stored access token, or null if not found.
  Future<String?> getAccess() async {
    return await _storage.read(key: 'access_token');
  }

  /// Deletes the stored access token.
  Future<void> deleteAccess() async {
    await _storage.delete(key: 'access_token');
  }

  /// Saves the refresh token securely.
  Future<void> saveRefresh(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  /// Retrieves the stored refresh token, or null if not found.
  Future<String?> getRefresh() async {
    return await _storage.read(key: 'refresh_token');
  }

  /// Deletes the stored refresh token.
  Future<void> deleteRefresh() async {
    await _storage.delete(key: 'refresh_token');
  }
}
