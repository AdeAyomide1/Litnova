import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> login(
      String email,
      String password,
      ) async {
    final response = await ApiService.login(email, password);
    if (response.statusCode == 200) {
      final token = response.data['token'];
      final refreshToken = response.data['refreshToken'];
      final user = response.data['data']['user'];

      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'user_id', value: user['id']);
      await _storage.write(key: 'user_role', value: user['role']);
      await _storage.write(key: 'user_name', value: user['name']);

      return user;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register(
      String name,
      String email,
      String password,
      ) async {
    final response = await ApiService.register(name, email, password);
    if (response.statusCode == 201) {
      final token = response.data['token'];
      final refreshToken = response.data['refreshToken'];
      final user = response.data['data']['user'];

      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'user_id', value: user['id']);
      await _storage.write(key: 'user_role', value: user['role']);
      await _storage.write(key: 'user_name', value: user['name']);

      return user;
    }
    return null;
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }
}
