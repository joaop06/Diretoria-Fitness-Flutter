import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/training_release.service.dart';

class BetDay {
  final int? id;
  final String? day;
  final String? name;
  final int? totalFaults;
  final double? utilization;
  final Bet? trainingBet;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;
  final List<TrainingRelease>? trainingReleases;

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
    try {
      return BetDay(
        id: json['id'],
        day: json['day'],
        name: json['name'],
        totalFaults: json['totalFaults'],
        utilization: json['utilization'],
        trainingBet: json['trainingBet'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        deletedAt: json['deletedAt'],
        trainingReleases: json['trainingReleases'] != null ||
                (json['trainingReleases'] as List).isNotEmpty
            ? (json['trainingReleases'] as List)
                .map((item) => TrainingRelease.fromJson(item))
                .toList()
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class BetDayService {
  final ApiService _apiService;

  BetDayService(this._apiService);
}
