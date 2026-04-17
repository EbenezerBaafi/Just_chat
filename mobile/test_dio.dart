import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: "https://just-chat-backend-5idn.onrender.com/api/",
  ));
  
  try {
    print("Testing POST to users/login/");
    var r = await dio.post('users/login/', data: {});
    print(r.data);
  } on DioException catch (e) {
    print("Error Code: ${e.response?.statusCode}");
    print("Error Data: ${e.response?.data}");
    print("URL requested: ${e.requestOptions.uri}");
  }
}
