import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    try {
      final response = await _api.login({"email": email, "password": password});

      _token = response.data['access'];
      await _storage.write(key: 'token', value: _token);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    await _api.register({
      "username": username,
      "email": email,
      "password": password,
      "password2": password,
    });
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}
