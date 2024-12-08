import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:daily_training_flutter/utils/colors.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
          child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo da aplicação
              Image.asset(
                'images/logo-diretoria-fitness.jpg', // Substitua pelo caminho da sua imagem
                height: 200,
              ),
              const SizedBox(height: 40),
              // Campo de e-mail
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: const TextStyle(color: AllColors.white),
                  filled: true,
                  fillColor: AllColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email, color: AllColors.gold),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AllColors.white),
              ),

              const SizedBox(height: 20),
              // Campo de senha
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle: const TextStyle(color: AllColors.white),
                  filled: true,
                  fillColor: AllColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: AllColors.gold),
                  suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: AllColors.gold,
                      ),
                      onPressed: _togglePasswordVisibility),
                ),
                obscureText: _obscureText,
                style: const TextStyle(color: AllColors.white),
              ),

              const SizedBox(height: 30),
              if (authProvider.errorMessage != null)
                Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: AllColors.red),
                ),
              // Botão "Entrar"
              authProvider.isLoading
                  ? const CircularProgressIndicator(
                      color: AllColors.gold,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Preencha todos os campos!',
                                style: TextStyle(color: AllColors.red),
                              ),
                            ),
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AllColors.gold,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Entrar",
                        style: TextStyle(fontSize: 18, color: AllColors.white),
                      ),
                    ),
              const SizedBox(height: 15),
              // Botão "Cadastrar Usuário"
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AllColors.gold),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cadastrar",
                  style: TextStyle(fontSize: 18, color: AllColors.gold),
                ),
              ),
            ],
          ),
        ),
      )),
      backgroundColor: const Color(0xFF1E1C1B),
    );
  }
}
