import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/CustomTextField.dart';
import 'package:daily_training_flutter/providers/users.provider.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // BackButtonInterceptor.add(backButtonInterceptor);
    _weightController.addListener(_formatWeightDynamically);
    _heightController.addListener(_formatHeightDynamically);
  }

  @override
  void dispose() {
    // BackButtonInterceptor.remove(backButtonInterceptor);
    _weightController.removeListener(_formatWeightDynamically);
    _heightController.removeListener(_formatHeightDynamically);
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushNamed(context, '/');
    return true;
  }

  void registerUser() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final usersProvider = Provider.of<UsersProvider>(context, listen: false);

      if (_formKey.currentState?.validate() ?? false) {
        final Map<String, dynamic> userData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        };

        // Condicionalmente adiciona 'weight' se preenchido, convertendo para String
        if (_weightController.text.isNotEmpty) {
          userData['weight'] = double.parse(_weightController.text);
        }

        // Condicionalmente adiciona 'height' se preenchido, convertendo para String
        if (_heightController.text.isNotEmpty) {
          userData['height'] = double.parse(_heightController.text);
        }

        await usersProvider.registerUser(userData);

        if (usersProvider.errorMessage != null) {
          throw Exception(
              usersProvider.errorMessage ?? 'Erro ao realizar o cadastro');
        }

        // Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Cadastro realizado com sucesso!',
            style: TextStyle(color: AllColors.green),
          )),
        );

        // Redireciona para a tela de login
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (e.toString().replaceFirst('Exception: ', '') ==
          'Token expirado. Faça o login novamente') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Token expirado. Faça o login novamente',
            style: TextStyle(color: AllColors.red),
          )),
        );
        Navigator.pushNamed(context, '/');
      }
      var errorMessage = 'Falha ao cadastrar usuário';
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
    return Scaffold(
      backgroundColor: AllColors.background,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AllColors.backgroundSidebar,
        title: const Text(
          'Cadastre-se e venha treinar!',
          style: TextStyle(fontSize: 16, color: AllColors.gold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AllColors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: "Nome",
                  hint: "João Borges",
                  controller: _nameController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nome é obrigatório'
                      : null,
                ),
                CustomTextField(
                  label: "E-mail",
                  hint: "joaoborges@gmail.com",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-mail é obrigatório';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  label: 'Senha',
                  obscureText: true,
                  hint: 'Mínimo de 6 caracteres',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Senha é obrigatória';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                CustomTextField(
                  suffix: 'kg',
                  isNumeric: true,
                  hint: 'Ex.: 71.2',
                  label: 'Peso (opcional)',
                  controller: _weightController,
                ),
                CustomTextField(
                  suffix: 'm',
                  isNumeric: true,
                  hint: 'Ex.: 1.75',
                  label: 'Altura (opcional)',
                  controller: _heightController,
                ),
                const SizedBox(height: 40),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: CustomElevatedButton(
                    isLoading: _isLoading,
                    backgroundColor: AllColors.gold,
                    onPressed: _isLoading ? null : registerUser,
                    child: const Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 16,
                        color: AllColors.text,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _formatWeightDynamically() {
    final currentText = _weightController.text;
    // Remove pontos para manipular o texto cru
    String text = currentText.replaceAll('.', '');

    // Evita chamadas desnecessárias ao TextEditingController
    if (currentText.endsWith('.') && currentText.length > 1) return;

    if (text.isEmpty) {
      // Garante que o campo seja limpo sem erros
      _weightController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }

    if (text.length == 1) {
      // Primeiro dígito: adiciona "0."
      final newText = text;
      _weightController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else {
      // Para 2 ou mais dígitos: remove o zero inicial e coloca o ponto na penúltima posição
      final trimmedText = text.startsWith('0')
          ? text.substring(1)
          : text; // Remove o zero inicial
      final beforeDecimal = trimmedText.substring(
          0, trimmedText.length - 1); // Tudo antes do último dígito
      final afterDecimal =
          trimmedText.substring(trimmedText.length - 1); // Último dígito
      final formatted = '$beforeDecimal.$afterDecimal';

      _weightController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  var oldHeightValue = '';
  void _formatHeightDynamically() {
    String text = _heightController.text;

    // Remove o ponto do texto, para garantir que a formatação será feita corretamente
    text = text.replaceAll('.', '');

    // Se o texto estiver vazio, não faz nada
    if (text.isEmpty) {
      _heightController.value = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }

    // Se a string tiver mais de 1 dígito e começar com '0', remove o zero
    if (text.length > 1 && text.startsWith('0')) {
      text = text.substring(1);
    }

    String newHeightValue;

    // Se o texto tiver 1 ou 2 dígitos, coloca o ponto na segunda posição
    if (text.length == 1) {
      // Exibe a primeira entrada como '1'
      newHeightValue = text;
    } else if (text.length == 2) {
      // Exibe dois números inteiros seguidos de um ponto, como '1.7'
      newHeightValue = '${text[0]}.${text[1]}';
    } else if (text.length == 3) {
      // Permite o número com até dois decimais, como '1.75'
      // newHeightValue = '${text.substring(0)}.${text.substring(1, 2)}';
      newHeightValue = '${text.substring(0, 1)}.${text.substring(1, 3)}';
    } else {
      newHeightValue = oldHeightValue;
    }

    if (newHeightValue.replaceAll('.', '') != oldHeightValue) {
      _heightController.value = TextEditingValue(
        text: newHeightValue,
        selection: TextSelection.collapsed(offset: newHeightValue.length),
      );

      oldHeightValue = newHeightValue;
    }
  }
}
