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
import 'package:daily_training_flutter/screens/verification_code.dart';

import 'package:daily_training_flutter/services/api.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/ranking.service.dart';
import 'package:daily_training_flutter/services/training_release.service.dart';

import 'package:daily_training_flutter/providers/auth.provider.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:daily_training_flutter/providers/email.provider.dart';
import 'package:daily_training_flutter/providers/users.provider.dart';
import 'package:daily_training_flutter/providers/ranking.provider.dart';
import 'package:daily_training_flutter/providers/participants.privider.dart';
import 'package:daily_training_flutter/providers/training_release.provider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmailProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                TrainingReleaseProvider(TrainingReleaseService(ApiService()))),
        ChangeNotifierProvider(
            create: (_) => RankingProvider(RankingService(ApiService()))),
        ChangeNotifierProvider(create: (_) => ParticipantsProvider()),
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
          '/': (context) => const SignInScreen(),
          '/bets': (context) => const BetsScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/new-bet': (context) => const NewBetScreen(),
          '/ranking': (context) => const RankingScreen(),
          '/edit-user': (context) => const EditUserScreen(),
          '/bet-details': (context) => const BetDetailsScreen(),
          '/edit-bet': (context) => const EditBetScreen(betId: ''),
        },
        onGenerateRoute: (settings) {
          // Verifica o nome da rota
          if (settings.name == '/verification-code') {
            // Extrai os argumentos da rota
            final args = settings.arguments != null
                ? settings.arguments as Map<String, dynamic>
                : null;
            final userId = args?['userId'] as int?;
            final email = args?['email'] as String?;
            final redirectRoute = args?['redirectRoute'] as String;
            final resendCodeWhenStarting =
                args?['resendCodeWhenStarting'] as bool;

            // Retorna a tela com o parâmetro extraído
            if (userId != null && email != null) {
              return MaterialPageRoute(
                builder: (context) => VerificationCodeScreen(
                  email: email,
                  userId: userId,
                  redirectRoute: redirectRoute,
                  resendCodeWhenStarting: resendCodeWhenStarting,
                ),
              );
            }
          }

          // Fallback para rotas desconhecidas
          return MaterialPageRoute(
            builder: (context) => const ErrorScreen(),
          );
        },
      ),
    );
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
