import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<bool> {
  final _secureStorage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: "https://fakestoreapi.com/"));

  AuthNotifier() : super(false) {
    _checkExistingToken();
  }

  /// Check if a token already exists (one-time login)
  Future<void> _checkExistingToken() async {
    final token = await _secureStorage.read(key: 'token');
    state = token != null;
  }

  /// Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {"username": username, "password": password}, // JSON payload
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print("Login Response: ${response.data}");
      print("Login Status Code: ${response.statusCode}");

      if (response.statusCode == 201 && response.data['token'] != null) {
        final token = response.data['token'] as String;

        // Save token securely for auto login
        await _secureStorage.write(key: 'token', value: token);

        // Save username/password in SharedPreferences (optional)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('password', password);

        state = true; // logged in
        return true;
      } else {
        state = false;
        return false;
      }
    } on DioException catch (e) {
      print("DioException: $e");
      state = false;
      return false;
    } catch (e) {
      print("Other Exception: $e");
      state = false;
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    state = false;
  }

  /// Get saved token (for API calls if needed)
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  /// Get saved credentials (optional)
  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username'),
      'password': prefs.getString('password'),
    };
  }
}
