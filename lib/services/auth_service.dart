import 'package:clone_whatsapp_base_code/constants/api_config.dart';
import 'package:dio/dio.dart';

class AuthService {
  static Dio api = ApiConfig.api();

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return {};
  }
}
