import 'package:daily_training_flutter/screens/bets.dart';

import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// class LoginScreen extends StatelessWidget {
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo da aplicação
              Image.asset(
                'logo-diretoria-fitness.jpg', // Substitua pelo caminho da sua imagem
                height: 200,
              ),
              const SizedBox(height: 40),
              // Campo de e-mail
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF282624),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.email, color: Color(0xFFCCA253)),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),
              // Campo de senha
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF282624),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFCCA253)),
                ),
                obscureText: true,
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 30),
              if (authProvider.errorMessage != null)
                Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              // Botão "Entrar"
              authProvider.isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Preencha todos os campos!')),
                          );
                          return;
                        }

                        await authProvider.login(
                          email,
                          password,
                        );

                        if (authProvider.errorMessage == null) {
                          Navigator.pushReplacementNamed(context, '/bets');
                        }

                        // final result = await ApiService.login(email, password);
                        // if (result['success']) {
                        //   final token = result['data']['accessToken'];
                        //   // Armazenar o token
                        //   Provider.of<AuthProvider>(context, listen: false)
                        //       .setToken(token);

                        //   // Redirecionar para a Home
                        //   Navigator.pushReplacementNamed(context, '/home');
                        // } else {
                        //   // Mostrar mensagem de erro
                        //   final errorMessage = result.containsKey('message') &&
                        //           result['message'] != null
                        //       ? result['message']
                        //       : result['error'];

                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(content: Text(errorMessage)),
                        //   );
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCCA253),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Entrar",
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF1E1C1B)),
                      ),
                    ),
              const SizedBox(height: 15),
              // Botão "Cadastrar Usuário"
              OutlinedButton(
                onPressed: () {
                  print("Cadastrar Usuário pressionado");
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCCA253)),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cadastrar",
                  style: TextStyle(fontSize: 18, color: Color(0xFFCCA253)),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1E1C1B),
    );
  }
}
