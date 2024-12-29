import 'dart:convert';
import 'dart:typed_data';
import 'package:daily_training_flutter/services/auth.service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://192.168.100.8:3000';
  static const String baseUrl = 'https://diretoriafitness.api.fluxocar.com.br';

  buildHeaders(accessToken, [String type = 'json']) {
    final headers = {
      'Authorization': 'Bearer $accessToken',
    };

    if (type == 'json') {
      headers['Content-Type'] = "application/json";
    }

    return headers;
  }

  // Função para buscar apostas do servidor
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final accessToken = await AuthService.getAccessToken();

    try {
      final response = await http.get(url, headers: buildHeaders(accessToken));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.statusCode == 401 &&
            json.decode(response.body)['message'] != 'Credenciais inválidas') {
          throw Exception('Token expirado. Faça o login novamente');
        } else {
          throw Exception('Falha ao buscar dados');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final accessToken = await AuthService.getAccessToken();

    try {
      final response = await http.post(
        url,
        body: jsonEncode(data),
        headers: buildHeaders(accessToken),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        if (response.statusCode == 401 &&
            json.decode(response.body)['message'] != 'Credenciais inválidas') {
          throw Exception('Token expirado. Faça o login novamente');
        }
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? error['error']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put({
    int? id,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    final accessToken = await AuthService.getAccessToken();
    final url = Uri.parse("$baseUrl$endpoint${id != null ? '/$id' : ''}");

    try {
      final response = await http.put(
        url,
        body: jsonEncode(data),
        headers: buildHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.statusCode == 401 &&
            json.decode(response.body)['message'] != 'Credenciais inválidas') {
          throw Exception('Token expirado. Faça o login novamente');
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? error['error']);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> patch(
      String endpoint, int id, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl$endpoint/$id");
    final accessToken = await AuthService.getAccessToken();

    try {
      final response = await http.patch(
        url,
        body: jsonEncode(data),
        headers: buildHeaders(accessToken),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        if (response.statusCode == 401 &&
            json.decode(response.body)['message'] != 'Credenciais inválidas') {
          throw Exception('Token expirado. Faça o login novamente');
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? error['error']);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String endpoint, int id) async {
    final url = Uri.parse("$baseUrl$endpoint/$id");
    final accessToken = await AuthService.getAccessToken();

    try {
      final response = await http.delete(
        url,
        headers: buildHeaders(accessToken),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401 &&
            json.decode(response.body)['message'] != 'Credenciais inválidas') {
          throw Exception('Token expirado. Faça o login novamente');
        } else {
          final error = json.decode(response.body);
          throw Exception(error['message'] ?? error['error']);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendImage(Uint8List image, String endpoint) async {
    final accessToken = await AuthService.getAccessToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl$endpoint"),
    );

    request.headers.addAll(buildHeaders(accessToken, 'form'));
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      image,
      filename: 'image.jpg',
    ));

    // Upload da imagem
    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (response.statusCode == 401) {
        throw Exception('Token expirado. Faça o login novamente');
      } else {
        throw Exception('Falha ao enviar imagem');
      }
    }
  }
}
