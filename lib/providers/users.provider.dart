import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/users.service.dart';

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

  Future<String> updateProfileImage(int userId, Uint8List image) async {
    return await _usersService.updateProfileImage(userId, image);
  }

  Future<User> setUserData(int userId) async {
    try {
      final userData = await UsersService.setUserData(userId);

      return userData;
    } catch (e) {
      rethrow;
    }
  }
}
