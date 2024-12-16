import 'package:daily_training_flutter/services/api.service.dart';

class User {
  final String name;
  final int wins;
  final int losses;
  final int totalFaults;
  final String? profileImagePath;

  User({
    required this.name,
    required this.wins,
    required this.losses,
    this.profileImagePath,
    required this.totalFaults,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      wins: json['wins'],
      losses: json['losses'],
      totalFaults: json['totalFaults'],
      profileImagePath: json['profileImagePath'],
    );
  }
}

class Ranking {
  final int id;
  final int score;
  final User user;

  Ranking({
    required this.id,
    required this.user,
    required this.score,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['id'],
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      score: json['score'],
    );
  }
}

class RankingService {
  final ApiService _apiService;

  RankingService(this._apiService);

  Future<List<Ranking>> getRanking() async {
    final response = await _apiService.get('/ranking');

    return (response["result"] as List)
        .map((item) => Ranking.fromJson(item))
        .toList();
  }
}
