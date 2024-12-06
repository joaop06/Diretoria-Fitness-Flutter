import 'dart:async';
import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/ranking_service.dart';

class RankingProvider with ChangeNotifier {
  List<Ranking> _ranking = [];
  List<Ranking> get ranking => _ranking;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final RankingService _rankingService;
  RankingProvider(this._rankingService);

  Future<void> getRanking() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ranking = await _rankingService.getRanking();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
