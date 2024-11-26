import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/screens/bets.dart';
import 'package:daily_training_flutter/screens/signup.dart';
import 'package:daily_training_flutter/screens/signin.dart';
import 'package:daily_training_flutter/screens/new_bet.dart';
import 'package:daily_training_flutter/screens/bet_details.dart';
import 'package:daily_training_flutter/services/api_service.dart';
import 'package:daily_training_flutter/services/bets_service.dart';
import 'package:daily_training_flutter/providers/bets_provider.dart';
import 'package:daily_training_flutter/providers/auth_provider.dart';
import 'package:daily_training_flutter/providers/users_provider.dart';
import 'package:daily_training_flutter/services/participants_service.dart';
import 'package:daily_training_flutter/providers/participants.privider.dart';

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
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
          // onGenerateRoute: (settings) {
          //   if (settings.name == '/bet-details') {
          //     // Verifica se os argumentos foram passados corretamente
          //     final args = settings.arguments as Map<String, dynamic>?;
          //     final betId = args?['id'];

          //     if (betId != null) {
          //       return MaterialPageRoute(
          //         builder: (context) => BetDetailsScreen(betId: betId),
          //       );
          //     }

          //     // Caso o argumento seja nulo ou inválido, redirecione para uma tela de erro ou outra ação
          //     return MaterialPageRoute(
          //       builder: (context) => const ErrorScreen(),
          //     );
          //   }

          //   // Outras rotas
          //   switch (settings.name) {
          //     case '/':
          //       return MaterialPageRoute(builder: (context) => SignInScreen());
          //     case '/new-bet':
          //       return MaterialPageRoute(builder: (context) => NewBetScreen());
          //     case '/bets':
          //       return MaterialPageRoute(
          //           builder: (context) => const BetsScreen());
          //     case '/signup':
          //       return MaterialPageRoute(
          //           builder: (context) => const SignUpScreen());
          //     default:
          //       return MaterialPageRoute(
          //         builder: (context) => const ErrorScreen(),
          //       );
          //   }
          // },
          routes: {
            '/': (context) => SignInScreen(),
            '/new-bet': (context) => NewBetScreen(),
            '/bets': (context) => const BetsScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/bet-details': (context) => const BetDetailsScreen(),
          },
        ));
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

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
