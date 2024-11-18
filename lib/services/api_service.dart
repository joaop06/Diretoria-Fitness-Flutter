import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dailytraining.api.fluxocar.com.br';

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Função para criar um novo usuário
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? error['error']);
      }

      return jsonDecode(response.body);
    } catch (e) {
      final errorMessage = e.toString().isNotEmpty
          ? e.toString()
          : 'Erro ao tentar se comunicar com o servidor';
      throw Exception(errorMessage);
    }
  }
}
