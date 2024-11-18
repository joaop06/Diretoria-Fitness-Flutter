import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.post("/auth/login", {
      "email": email,
      "password": password,
    });

    if (response.containsKey("accessToken")) {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", response["accessToken"]);
      } catch (e) {
        throw Exception("Erro ao salvar o token");
      }
    } else {
      throw Exception("Token de acesso não encontrado");
    }
  }
}
