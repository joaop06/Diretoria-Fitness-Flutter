import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/bets_service.dart';

class BetDetailsScreen extends StatelessWidget {
  final Bet bet;

  BetDetailsScreen({required this.bet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1c1b),
      appBar: AppBar(
        title: const Text(
          'Detalhes da Aposta',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF282624),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/bets');
          },
        ),
      ),
      body: Center(
        child: Text(
          'Detalhes da aposta ${bet.id}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
