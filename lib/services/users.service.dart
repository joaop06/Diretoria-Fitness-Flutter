import 'package:daily_training_flutter/services/api.service.dart';

class User {
  final int? id;
  final String? name;
  final String? email;
  final double? weight;
  final double? height;
  final int? wins;
  final int? losses;
  final int? totalFaults;
  final String? profileImagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.weight,
    this.height,
    this.wins,
    this.losses,
    this.totalFaults,
    this.profileImagePath,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      weight: json['weight'],
      height: json['height'],
      wins: json['wins'],
      losses: json['losses'],
      totalFaults: json['totalFaults'],
      profileImagePath: json['profileImagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
    );
  }
}

class UsersService {
  final ApiService _apiService = ApiService();

  // Função para realizar o cadastro do usuário
  Future<String> registerUser(Map<String, dynamic> userData) async {
    await _apiService.post('/users', userData);
    return 'Cadastro realizado com sucesso!';
  }
}
