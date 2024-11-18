import 'package:daily_training_flutter/services/api_service.dart';

class UsersService {
  final ApiService _apiService = ApiService();

  // Função para realizar o cadastro do usuário
  Future<String> registerUser(Map<String, dynamic> userData) async {
    await _apiService.post('/users', userData);
    return 'Cadastro realizado com sucesso!';
  }
}
