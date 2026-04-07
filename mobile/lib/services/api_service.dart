import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://172.23.48.1:8000/api", // 🔥 replace with your IP
      headers: {"Content-Type": "application/json"},
    ),
  );

  // REGISTER
  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post("/users/register/", data: data);
  }

  // LOGIN
  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post("/users/login/", data: data);
  }

  // GET PROFILE
  Future<Response> getProfile(String token) async {
    return await _dio.get(
      "/users/profile/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // GET USERS
  Future<Response> getUsers(String token) async {
    return await _dio.get(
      "/users/all/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
