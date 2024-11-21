import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/screens/bets.dart';
import 'package:daily_training_flutter/screens/signup.dart';
import 'package:daily_training_flutter/screens/signin.dart';
import 'package:daily_training_flutter/screens/new_bet.dart';
import 'package:daily_training_flutter/services/api_service.dart';
import 'package:daily_training_flutter/services/bets_service.dart';
import 'package:daily_training_flutter/providers/bets_provider.dart';
import 'package:daily_training_flutter/providers/auth_provider.dart';
import 'package:daily_training_flutter/providers/users_provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(
            create: (_) => BetsProvider(BetsService(ApiService()))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Diretoria Fitness',
          initialRoute: '/',
          routes: {
            '/': (context) => SignInScreen(),
            '/bets': (context) => BetsScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/bet-details': (context) => BetsScreen(),
            '/new-bet': (context) => NewBetScreen(),
          },
        ));
  }
}
