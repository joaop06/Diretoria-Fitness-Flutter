import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:daily_training_flutter/screens/bets.dart';
import 'package:daily_training_flutter/screens/signup.dart';
import 'package:daily_training_flutter/screens/signin.dart';
import 'package:daily_training_flutter/screens/new_bet.dart';
import 'package:daily_training_flutter/screens/ranking.dart';
import 'package:daily_training_flutter/screens/edit_bet.dart';
import 'package:daily_training_flutter/screens/edit_user.dart';
import 'package:daily_training_flutter/screens/bet_details.dart';

import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/ranking.service.dart';
import 'package:daily_training_flutter/services/participants.service.dart';
import 'package:daily_training_flutter/services/training_release.service.dart';

import 'package:daily_training_flutter/providers/auth.provider.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:daily_training_flutter/providers/users.provider.dart';
import 'package:daily_training_flutter/providers/ranking.provider.dart';
import 'package:daily_training_flutter/providers/participants.privider.dart';
import 'package:daily_training_flutter/providers/training_release.provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                TrainingReleaseProvider(TrainingReleaseService(ApiService()))),
        ChangeNotifierProvider(
            create: (_) => RankingProvider(RankingService(ApiService()))),
        ChangeNotifierProvider(
            create: (_) =>
                ParticipantsProvider(ParticipantsService(ApiService()))),
        ChangeNotifierProvider(
            create: (_) => BetsProvider(BetsService(ApiService()))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Diretoria Fitness',
          initialRoute: '/',
          routes: {
            '/': (context) => SignInScreen(),
            '/new-bet': (context) => NewBetScreen(),
            '/bets': (context) => const BetsScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/ranking': (context) => const RankingScreen(),
            '/bet-details': (context) => const BetDetailsScreen(),
            '/edit-bet': (ctx) => const EditBetScreen(betId: ''),
            '/edit-user': (ctx) => const EditUserScreen(),
          },
        ));
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Erro")),
      body: const Center(
        child: Text("Algo deu errado!"),
      ),
    );
  }
}
