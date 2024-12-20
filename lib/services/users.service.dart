import 'dart:convert';

import 'package:daily_training_flutter/services/api.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int? id;
  final String? name;
  final String? email;
  final double? weight;
  final double? bmi;
  final double? height;
  final int? wins;
  final int? losses;
  final int? totalFaults;
  final String? profileImagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;
  final Object? userLogs;
  final Object? betsParticipated;

  User({
    this.id,
    this.name,
    this.email,
    this.weight,
    this.height,
    this.bmi,
    this.wins,
    this.losses,
    this.totalFaults,
    this.profileImagePath,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userLogs,
    this.betsParticipated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      weight: json['weight'],
      height: json['height'],
      bmi: json['bmi'],
      wins: json['wins'],
      losses: json['losses'],
      totalFaults: json['totalFaults'],
      profileImagePath: json['profileImagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
      userLogs: json['userLogs'],
      betsParticipated: json['betsParticipated'],
    );
  }
}

class UsersService {
  final ApiService _apiService = ApiService();

  static instancePrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Função para realizar o cadastro do usuário
  Future<String> registerUser(Map<String, dynamic> userData) async {
    await _apiService.post('/users', userData);
    return 'Cadastro realizado com sucesso!';
  }

  static setUserData(int userId) async {
    final apiService = ApiService();
    final userData = await apiService.get('/users/$userId');

    final prefs = await instancePrefs();
    final userEncoded = jsonEncode(userData);
    await prefs.setString("userData", userEncoded);
  }

  static getUserData() async {
    final prefs = await instancePrefs();
    final String? userDataString = prefs.getString("userData");

    if (userDataString != null) {
      try {
        return User.fromJson(jsonDecode(userDataString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
