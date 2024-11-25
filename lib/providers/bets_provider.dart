import 'dart:async';
import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/bets_service.dart';

class BetsProvider with ChangeNotifier {
  List<Bet> _bets = [];
  List<Bet> get bets => _bets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Bet? _highlightedBet = Bet();
  Bet? get highlightedBet => _highlightedBet;

  final BetsService _betsService;
  BetsProvider(this._betsService);

  Future<void> fetchBets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bets = await _betsService.getBets();

      _highlightedBet = _bets.firstWhere(
        (bet) => bet.status == 'Em Andamento',
        orElse: () {
          final agendadaBets = _bets
              .where(
                  (bet) => bet.status == 'Agendada' && bet.initialDate != null)
              .toList();
          if (agendadaBets.isEmpty) {
            return Bet(); // Retorna um objeto vazio caso não encontre nenhuma aposta 'Agendada'
          }
          return agendadaBets.reduce(
              (a, b) => a.initialDate!.isBefore(b.initialDate!) ? a : b);
        },
      );

      _bets = _bets.where((Bet bet) => bet.id != _highlightedBet?.id).toList();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> create(Map<String, dynamic> betData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _betsService.create(betData);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getBetDetails(int? id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bets = [await _betsService.getBetDetails(id!)];
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
