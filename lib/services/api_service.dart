import 'dart:convert';
import 'package:daily_training_flutter/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://localhost:3000';
  static const String baseUrl = 'https://dailytraining.api.fluxocar.com.br';

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final accessToken = await AuthService.getAccessToken();

    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? error['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

// Função para buscar apostas do servidor
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final accessToken = await AuthService.getAccessToken();

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao buscar dados');
      }
    } catch (e) {
      rethrow;
    }
  }
}
