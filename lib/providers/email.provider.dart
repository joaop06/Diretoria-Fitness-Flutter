import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/email.service.dart';

class EmailProvider with ChangeNotifier {
  final EmailService _emailService = EmailService();
  String? _errorMessage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future resendVerificationCode(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _emailService.resendVerificationCode(userId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
