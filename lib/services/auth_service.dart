import 'dart:convert';
import 'package:flutter/material.dart';

import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_training_flutter/services/users_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  static getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userDataString = prefs.getString("userData");

    if (userDataString != null) {
      try {
        return User.fromJson(jsonDecode(userDataString));
      } catch (e) {
        print("Erro ao decodificar os dados do usuário: $e");
        return null;
      }
    }
    return null; // Retorna null se não houver dados salvos
  }

  static Future<void> signup(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.remove('accessToken');

    await Navigator.pushNamed(context, '/');
  }

  Future<void> signin(String email, String password) async {
    final response = await _apiService.post("/auth/login", {
      "email": email,
      "password": password,
    });

    if (response.containsKey("accessToken")) {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", response["accessToken"]);

        final userEncoded = jsonEncode(response["user"]);
        await prefs.setString("userData", userEncoded);
      } catch (e) {
        throw Exception("Erro ao salvar o token ou dados do usuário: $e");
      }
    } else {
      throw Exception("Token de acesso não encontrado");
    }
  }
}
