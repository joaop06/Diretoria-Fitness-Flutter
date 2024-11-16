import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:3000'; // Substitua pela sua URL.

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
}
