import 'package:daily_training_flutter/services/api.service.dart';

class UserRanking {
  final int wins;
  final int losses;
  final String name;
  final int totalFaults;
  final int totalTrainingDays;
  final int totalParticipations;
  final String? profileImagePath;

  UserRanking({
    required this.name,
    required this.wins,
    required this.losses,
    this.profileImagePath,
    required this.totalFaults,
    required this.totalTrainingDays,
    required this.totalParticipations,
  });

  factory UserRanking.fromJson(Map<String, dynamic> json) {
    return UserRanking(
      name: json['name'],
      wins: json['wins'],
      losses: json['losses'],
      totalFaults: json['totalFaults'],
      profileImagePath: json['profileImagePath'],
      totalTrainingDays: json['totalTrainingDays'],
      totalParticipations: json['totalParticipations'],
    );
  }
}

class Ranking {
  final int score;
  final UserRanking user;

  Ranking({
    required this.user,
    required this.score,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      score: json['score'],
      user: UserRanking.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class RankingService {
  final ApiService _apiService;

  RankingService(this._apiService);

  Future<List<Ranking>> getRanking() async {
    final response = await _apiService.get<Map<String, dynamic>>('/ranking');

    return (response["result"] as List)
        .map((item) => Ranking.fromJson(item))
        .toList();
  }
}
