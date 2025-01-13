import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/users.service.dart';

class Participants {
  final int? id;
  final int? faults;
  final bool? penaltyPaid;
  final double? penaltyAmount;
  final bool? declassified;
  final double? utilization;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;
  final User? user;

  Participants({
    this.id,
    this.faults,
    this.penaltyPaid,
    this.penaltyAmount,
    this.declassified,
    this.utilization,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.user,
  });

  factory Participants.fromJson(Map<String, dynamic> json) {
    try {
      return Participants(
        id: json['id'],
        faults: json['faults'],
        penaltyPaid: json['penaltyPaid'],
        utilization: json['utilization'],
        declassified: json['declassified'],
        penaltyAmount: json['penaltyAmount']?.toDouble(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        deletedAt: json['deletedAt'],
        user: User.fromJson(json['user']),
      );
    } catch (e) {
      rethrow;
    }
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

  Future<List<Participants>> participantsByTrainingBet(int betId) async {
    try {
      final result = await apiService
          .get<List<dynamic>>('/participants/by-training-bet/$betId');
      return result.map((p) => Participants.fromJson(p)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Participants>> winningParticipants(int betId) async {
    try {
      final result =
          await apiService.get<List<dynamic>>('/participants/winning/$betId');
      return result.map((p) => Participants.fromJson(p)).toList();
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
