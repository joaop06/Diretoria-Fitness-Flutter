import 'dart:async';

import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/bets_service.dart';

class BetsProvider with ChangeNotifier {
  bool _isLoading = false;
  final BetsService betsService;

  List<Bet> _bets = [];
  Bet? _highlightedBet = Bet();

  List<Bet> get bets => _bets;
  bool get isLoading => _isLoading;
  Bet? get highlightedBet => _highlightedBet;

  BetsProvider(this.betsService);

  Future<void> fetchBets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bets = await betsService.getBets();

      _highlightedBet = _bets.firstWhere(
        (bet) => bet.status == 'Em Andamento',
        orElse: () => _bets.firstWhere(
          (bet) =>
              bet.status == 'Agendada' &&
              bet.initialDate != null &&
              bet.initialDate!.isAfter(DateTime.now()),
          orElse: () => Bet(),
        ),
      );

      _bets = _bets.where((Bet bet) => bet.id != _highlightedBet?.id).toList();
    } catch (e) {
      print(
          'Erro ao buscar apostas ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
