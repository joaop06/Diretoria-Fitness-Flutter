import 'package:flutter/material.dart';
import 'package:daily_training_flutter/services/bets_service.dart';

class NewBetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1c1b),
      appBar: AppBar(
        title: const Text(
          'Nova Aposta',
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
      body: const Center(
          child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Data inicial'),
          ),
          SizedBox(height: 40),
          TextField(
            decoration: InputDecoration(labelText: 'Data final'),
          ),
        ],
      )),
    );
  }
}
