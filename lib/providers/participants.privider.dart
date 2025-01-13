import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/participants.service.dart';

class ParticipantsProvider with ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ParticipantsService participantsService;
  ParticipantsProvider({ParticipantsService? participantsService})
      : participantsService = participantsService ?? ParticipantsService();

  Future<void> create(Map<String, dynamic> participantData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await participantsService.create(participantData);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Participants>> participantsByTrainingBet(int betId) async {
    try {
      final result = await participantsService.participantsByTrainingBet(betId);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Participants>> winningParticipants(int betId) async {
    try {
      final result = await participantsService.winningParticipants(betId);
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
      final result = await participantsService.updatePenaltyPaid(
        participantId,
        trainingBetId,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
