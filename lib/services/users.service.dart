import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_training_flutter/services/api.service.dart';

class Log {
  final int? id;
  final int? userId;
  final double? value;
  final String? fieldName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;

  Log({
    this.id,
    this.value,
    this.userId,
    this.fieldName,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    try {
      return Log(
        id: json['id'],
        userId: json['userId'],
        fieldName: json['fieldName'],
        value: double.parse(json['value']),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        deletedAt: json['deletedAt'],
      );
    } catch (e) {
      rethrow;
    }
  }
}

class UserLogs {
  final List<Log>? bmiLogs;
  final List<Log>? heightLogs;
  final List<Log>? weightLogs;

  UserLogs({
    this.bmiLogs,
    this.heightLogs,
    this.weightLogs,
  });

  factory UserLogs.fromJson(Map<String, dynamic> json) {
    try {
      return UserLogs(
        bmiLogs: (json['bmiLogs'] as List)
            .map((item) => Log.fromJson(item))
            .toList(),
        heightLogs: (json['heightLogs'] as List)
            .map((item) => Log.fromJson(item))
            .toList(),
        weightLogs: (json['weightLogs'] as List)
            .map((item) => Log.fromJson(item))
            .toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

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
  final int? totalTrainingDays;
  final int? totalParticipations;
  final String? profileImagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;
  final UserLogs? userLogs;

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
    this.totalTrainingDays,
    this.totalParticipations,
    this.profileImagePath,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userLogs,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as int?,
        wins: json['wins'] as int?,
        bmi: json['bmi']?.toDouble(),
        name: json['name'] as String?,
        losses: json['losses'] as int?,
        email: json['email'] as String?,
        weight: json['weight']?.toDouble(),
        height: json['height']?.toDouble(),
        totalFaults: json['totalFaults'] as int?,
        totalTrainingDays: json['totalTrainingDays'] as int?,
        profileImagePath: json['profileImagePath'] as String?,
        totalParticipations: json['totalParticipations'] as int?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        deletedAt: json['deletedAt'],
        userLogs: json['userLogs'] != null
            ? UserLogs.fromJson(json['userLogs'])
            : null,
      );
    } catch (e) {
      rethrow;
    }
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

  Future<String> update(int userId, Map<String, dynamic> object) async {
    await _apiService.patch('/users', userId, object);
    return 'Cadastro realizado com sucesso!';
  }

  Future<String> updateProfileImage(userId, image) async {
    try {
      await _apiService.sendImage(
        image,
        '/users/profile-image/$userId',
      );
      return 'Imagem atualizada com sucesso!';
    } catch (error) {
      throw Exception('Erro ao atualizar imagem');
    }
  }

  Future<String> resetPassword(
      int userId, String oldPassword, String newPassword) async {
    try {
      final object = {
        'userId': userId,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      await _apiService.put(endpoint: '/users/change-password', data: object);
      return 'Senha alterada com sucesso!';
    } catch (e) {
      throw Exception('Erro ao atualizar imagem');
    }
  }

  static setUserData(int userId) async {
    final apiService = ApiService();
    final userData =
        await apiService.get<Map<String, dynamic>>('/users/$userId');

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
