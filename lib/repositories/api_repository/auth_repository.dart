import 'package:clone_whatsapp_base_code/services/auth_service.dart';

class AuthRepository {

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await AuthService.login(email, password);
  }

}
