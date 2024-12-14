import 'package:flutter/material.dart';

class AllColors {
  // Status Colors
  static const statusBet = {
    'Encerrada': AllColors.red,
    'Agendada': AllColors.orange,
    'Em Andamento': AllColors.green,
  };

  // Native Colors
  static const black = Color.fromARGB(255, 0, 0, 0);
  static const red = Color.fromRGBO(244, 67, 54, 1);
  static const gold = Color.fromRGBO(204, 162, 83, 1);
  static const blue = Color.fromRGBO(33, 150, 243, 1);
  static const green = Color.fromRGBO(76, 175, 80, 1);
  static const grey = Color.fromRGBO(158, 158, 158, 1);
  static const orange = Color.fromRGBO(255, 152, 0, 1);
  static const softBlack = Color.fromARGB(80, 0, 0, 0);
  static const transparent = Color.fromRGBO(0, 0, 0, 0);
  static const white = Color.fromRGBO(255, 255, 255, 1);
  static const softWhite = Color.fromRGBO(255, 255, 255, 0.702);

  // Components Colors
  static const text = AllColors.white;
  static const card = Color.fromRGBO(41, 40, 38, 1);
  static const hoverCard = Color.fromRGBO(59, 58, 55, 1);
  static const background = Color.fromRGBO(20, 19, 18, 0.98);
  static const backgroundModal = Color.fromARGB(97, 0, 0, 0);
  static const softGold = Color.fromRGBO(204, 162, 83, 0.456);
  static const backgroundSidebar = Color.fromRGBO(0, 0, 0, 0.5);
}
