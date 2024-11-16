import 'package:flutter/material.dart';

class BetsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apostas"),
      ),
      body: Center(
        child: Text("Bem-vindo à tela de apostas!"),
      ),
    );
  }
}
