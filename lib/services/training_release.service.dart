import 'dart:typed_data';

import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/bet_day.service.dart';
import 'package:daily_training_flutter/services/participants.service.dart';

class TrainingRelease {
  final int? id;
  final String? trainingType;
  final String? comment;
  final String? imagePath;
  final Participants? participant;
  final BetDay? betDay;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;

  TrainingRelease({
    this.id,
    this.trainingType,
    this.comment,
    this.imagePath,
    this.participant,
    this.betDay,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TrainingRelease.fromJson(Map<String, dynamic> json) {
    try {
      return TrainingRelease(
        id: json['id'],
        trainingType: json['trainingType'],
        comment: json['comment'],
        imagePath: json['imagePath'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        deletedAt: json['deletedAt'],
        participant: Participants.fromJson(json['participant']),
        betDay: json['betDay'] != null ? BetDay.fromJson(json['betDay']) : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class TrainingReleaseService {
  final ApiService _apiService;

  TrainingReleaseService(this._apiService);

  Future<String> create({
    required Uint8List image,
    required Map<String, dynamic> trainingRelease,
  }) async {
    final int trainingId;
    const endpoint = '/training-releases';

    try {
      // Inserção do registro do treino
      final trainingResponse =
          await _apiService.post(endpoint, data: trainingRelease);

      trainingId = trainingResponse['id'];
    } catch (e) {
      rethrow;
    }

    try {
      await _apiService.sendImage(
        image,
        '$endpoint/photo/$trainingId',
      );
      return 'Treino lançado com sucesso!';
    } catch (error) {
      await _apiService.delete(endpoint, trainingId);
      throw Exception('Erro ao enviar imagem do treino');
    }
  }
}
