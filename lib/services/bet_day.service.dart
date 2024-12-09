import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/training_release.service.dart';

class BetDay {
  final int? id;
  final String? day;
  final String? name;
  final int? totalFaults;
  final int? utilization;
  final Bet? trainingBet;
  final TrainingRelease? trainingReleases;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;

  BetDay({
    this.id,
    this.day,
    this.name,
    this.totalFaults,
    this.utilization,
    this.trainingBet,
    this.trainingReleases,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory BetDay.fromJson(Map<String, dynamic> json) {
    return BetDay(
      id: json['id'],
      day: json['day'],
      name: json['name'],
      totalFaults: json['totalFaults'],
      utilization: json['utilization'],
      trainingBet: json['trainingBet'],
      trainingReleases: json['trainingReleases'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
    );
  }
}

class BetDayService {
  final ApiService _apiService;

  BetDayService(this._apiService);
}
