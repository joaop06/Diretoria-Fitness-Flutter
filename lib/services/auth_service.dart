import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> login(String email, String password) async {
    final response = await _apiService.post("/auth/login", {
      "email": email,
      "password": password,
    });

    if (response.containsKey("accessToken")) {
      await _storage.write(key: "accessToken", value: response["accessToken"]);
    } else {
      throw Exception("Token de acesso não encontrado");
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: "accessToken");
  }
}
