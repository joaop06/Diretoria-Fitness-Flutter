import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/CustomTextField.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // BackButtonInterceptor.add(backButtonInterceptor);
  }

  @override
  void dispose() {
    // BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushNamed(context, '/');
    return true;
  }

  Future<void> signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

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

      if (authProvider.errorMessage != null) {
        throw Exception(
          authProvider.errorMessage ?? 'Erro ao realizar o cadastro',
        );
      }

      Navigator.pushReplacementNamed(context, '/bets');
    } catch (e) {
      var errorMessage = 'Falha ao realizar o login';
      if (e is Exception) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          errorMessage,
          style: const TextStyle(color: AllColors.red),
        )),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentPage = 0.0;
    PageController pageController = PageController();

    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page ?? 0.0;
      });
    });

    final scale = (1 - (currentPage).abs()).clamp(1.0, 1.2);
    final scaleWidth = (MediaQuery.of(context).size.width) * scale;
    final scaleHeight = (MediaQuery.of(context).size.height) * scale;

    return Scaffold(
      backgroundColor: AllColors.background,
      body: Center(
          child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: scaleWidth / 2,
                  maxHeight: scaleHeight / 2,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 4.0,
                    color: AllColors.gold,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'images/logo-diretoria-fitness.jpg',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              CustomTextField(
                label: "E-mail",
                controller: emailController,
                hint: "joaoborges@gmail.com",
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email, color: AllColors.gold),
              ),
              CustomTextField(
                label: "Senha",
                hint: "",
                obscureText: true,
                controller: passwordController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.lock, color: AllColors.gold),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              CustomElevatedButton(
                padding: null,
                onPressed: signIn,
                isLoading: _isLoading,
                backgroundColor: AllColors.gold,
                maximumSize: const Size(150, 45),
                minimumSize: const Size(150, 45),
                child: const Text(
                  "Entrar",
                  style: TextStyle(fontSize: 16, color: AllColors.white),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                style: OutlinedButton.styleFrom(
                  maximumSize: const Size(200, 45),
                  minimumSize: const Size(200, 45),
                  side: const BorderSide(color: AllColors.gold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cadastrar",
                  style: TextStyle(fontSize: 16, color: AllColors.gold),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
