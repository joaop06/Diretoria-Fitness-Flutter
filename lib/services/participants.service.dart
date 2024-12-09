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
  final ApiService _apiService;

  ParticipantsService(this._apiService);

  Future<String> create(Map<String, dynamic> participantData) async {
    await _apiService.post('/participants', participantData);
    return 'Participante cadastrado com sucesso!';
  }
}
