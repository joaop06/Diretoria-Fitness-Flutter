import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/bet_day.service.dart';
import 'package:daily_training_flutter/services/participants.service.dart';

class Bet {
  final int? id;
  final int? duration;
  final DateTime? initialDate;
  final DateTime? finalDate;
  final int? faultsAllowed;
  final double? minimumPenaltyAmount;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Null deletedAt;
  final List<BetDay>? betDays;
  final List<Participants>? participants;

  Bet({
    this.id,
    this.duration,
    this.initialDate,
    this.finalDate,
    this.faultsAllowed,
    this.minimumPenaltyAmount,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.betDays,
    this.participants,
  });

  factory Bet.fromJson(Map<String, dynamic> json) {
    try {
      return Bet(
        id: json['id'],
        duration: json['duration'],
        initialDate: DateTime.parse(json['initialDate']),
        finalDate: DateTime.parse(json['finalDate']),
        faultsAllowed: json['faultsAllowed'],
        minimumPenaltyAmount: json['minimumPenaltyAmount'],
        status: json['status'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        deletedAt: json['deletedAt'],
        betDays: json['betDays'] != null
            ? (json['betDays'] as List)
                .map((item) => BetDay.fromJson(item))
                .toList()
            : null,
        participants: json['participants'] != null
            ? (json['participants'] as List)
                .map((item) => Participants.fromJson(item))
                .toList()
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class BetsService {
  final ApiService _apiService;

  BetsService(this._apiService);

  Future<List<Bet>> getBets() async {
    final betsData =
        await _apiService.get<Map<String, dynamic>>('/training-bets');
    return (betsData['rows'] as List)
        .map((item) => Bet.fromJson(item))
        .toList();
  }

  Future<String> create(Map<String, dynamic> betData) async {
    await _apiService.post('/training-bets', data: betData);
    return 'Aposta criada com sucesso!';
  }

  Future<Bet> getBetDetails(int id) async {
    final bet =
        await _apiService.get<Map<String, dynamic>>('/training-bets/$id');
    return Bet.fromJson(bet);
  }

  Future<String> update(int id, object) async {
    await _apiService.patch('/training-bets', id, object);
    return 'Aposta atualizada com sucesso';
  }

  Future<String> delete(int id) async {
    await _apiService.delete('/training-bets', id);
    return 'Aposta apagada com sucesso';
  }
}
