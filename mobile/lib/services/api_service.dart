import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.212.40.60/api/",
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

  // START OR GET CONVERSATION
  Future<Response> startConversation(String token, int userId) async {
    return await _dio.post(
      "/chat/conversations/start/",
      data: {"user_id": userId},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // GET MESSAGES
  Future<Response> getMessages(String token, int conversationId) async {
    return await _dio.get(
      "/chat/conversations/$conversationId/messages/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // SEND MESSAGE
  Future<Response> sendMessage(
    String token,
    int conversationId,
    String content,
  ) async {
    return await _dio.post(
      "/chat/conversations/$conversationId/send/",
      data: {"content": content},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
