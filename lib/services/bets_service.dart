import 'package:daily_training_flutter/services/api_service.dart';

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
  });

  factory Bet.fromJson(Map<String, dynamic> json) {
    return Bet(
      id: json['id'],
      duration: json['duration'],
      initialDate: DateTime.parse(json['initialDate']),
      finalDate: DateTime.parse(json['finalDate']),
      faultsAllowed: json['faultsAllowed'],
      minimumPenaltyAmount: json['minimumPenaltyAmount'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
    );
  }
}

class BetsService {
  final ApiService _apiService;

  BetsService(this._apiService);

  Future<List<Bet>> getBets() async {
    final betsData = await _apiService.get('/training-bets');
    return (betsData["rows"] as List)
        .map((item) => Bet.fromJson(item))
        .toList();
  }

  Future<String> create(Map<String, dynamic> betData) async {
    await _apiService.post('/training-bets', betData);
    return 'Aposta criada com sucesso!';
  }
}