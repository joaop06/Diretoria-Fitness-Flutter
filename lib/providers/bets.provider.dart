import 'dart:async';
import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/bets.service.dart';

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

      // Determinar a aposta destacada
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

      // Filtrar a aposta destacada da lista principal
      _bets = _bets.where((Bet bet) => bet.id != _highlightedBet?.id).toList();

      // Ordenar a lista _bets pelo status
      _bets.sort((a, b) {
        if (a.status == 'Em Andamento' && b.status != 'Em Andamento') {
          return -1;
        } else if (a.status != 'Em Andamento' && b.status == 'Em Andamento') {
          return 1;
        }
        return 0; // Mantém a ordem original se ambos não forem "Em Andamento"
      });
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

  Future<void> update(int id, object) async {
    try {
      await _betsService.update(id, object);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    try {
      await _betsService.delete(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
