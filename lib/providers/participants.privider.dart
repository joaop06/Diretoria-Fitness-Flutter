import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/participants.service.dart';

class ParticipantsProvider with ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final ParticipantsService _participantsService;
  ParticipantsProvider(this._participantsService);

  Future<void> create(Map<String, dynamic> participantData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _participantsService.create(participantData);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
