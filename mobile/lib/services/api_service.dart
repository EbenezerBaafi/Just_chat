import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.194.233.60:8000/api/",
      headers: {"Content-Type": "application/json"},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post('/users/login/', data: data);
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post("/users/register/", data: data);
  }

  Future<Response> getProfile(String token) async {
    return await _dio.get(
      "/users/profile/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  Future<Response> getUsers(String token) async {
    return await _dio.get(
      "/users/all/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
