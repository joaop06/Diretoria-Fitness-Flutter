import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/users_service.dart';

class UsersProvider with ChangeNotifier {
  String? _errorMessage;
  bool _isLoading = false;
  final UsersService _usersService = UsersService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Função para registrar o usuário
  Future<void> registerUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _usersService.registerUser(userData);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
