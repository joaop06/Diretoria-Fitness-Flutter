import 'package:daily_training_flutter/services/api.service.dart';

class Participants {
  final int? id;
  final int? faults;
  final bool? declassified;
  final double? utilization;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;

  Participants({
    this.id,
    this.faults,
    this.declassified,
    this.utilization,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    return Participants(
      id: json['id'],
      faults: json['faults'],
      declassified: json['declassified'],
      utilization: json['utilization'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
    );
  }
}

class ParticipantsService {
  final ApiService apiService;

  ParticipantsService({
    ApiService? apiService,
  }) : apiService = apiService ?? ApiService();

  Future<String> create(Map<String, dynamic> participantData) async {
    await apiService.post('/participants', participantData);
    return 'Participante cadastrado com sucesso!';
  }

  Future<List<dynamic>> participantsByTrainingBet(int betId) async {
    try {
      final result = await apiService
          .get<List<dynamic>>('/participants/by-training-bet/$betId');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> winningParticipants(int betId) async {
    try {
      final result =
          await apiService.get<List<dynamic>>('/participants/winning/$betId');
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future updatePenaltyPaid(
    int participantId,
    int trainingBetId,
  ) async {
    try {
      final result = await apiService.put(
        endpoint: '/participants/penalty-paid',
        data: {'participantId': participantId, 'trainingBetId': trainingBetId},
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
