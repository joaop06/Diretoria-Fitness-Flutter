import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/providers/users_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_formatWeightDynamically);
    _heightController.addListener(
        _formatHeightDynamically); // Adiciona o listener para o height também
  }

  @override
  void dispose() {
    _weightController.removeListener(_formatWeightDynamically);
    _heightController.removeListener(
        _formatHeightDynamically); // Remove o listener para o height também
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
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

  void registerUser() async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);

    if (_formKey.currentState?.validate() ?? false) {
      final userData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      // Condicionalmente adiciona 'weight' se preenchido, convertendo para String
      if (_weightController.text.isNotEmpty) {
        userData['weight'] = double.parse(_weightController.text).toString();
      }

      // Condicionalmente adiciona 'height' se preenchido, convertendo para String
      if (_heightController.text.isNotEmpty) {
        userData['height'] = double.parse(_heightController.text).toString();
      }

      await usersProvider.registerUser(userData);

      if (usersProvider.errorMessage == null) {
        // Mostra uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Cadastro realizado com sucesso!',
            style: TextStyle(color: Colors.green),
          )),
        );

        // Redireciona para a tela de login
        Navigator.pushReplacementNamed(context, '/');
      } else {
        // Exibe o erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  usersProvider.errorMessage ?? 'Erro ao realizar o cadastro')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1e1c1b),
      appBar: AppBar(
        backgroundColor: const Color(0xFF282624),
        title: const Text(
          'Cadastro',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    hintText: 'João Borges',
                    hintStyle: TextStyle(color: Colors.white70),
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFcca253)),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Nome é obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'E-mail *',
                    hintText: 'joaoborges@gmail.com',
                    hintStyle: TextStyle(color: Colors.white70),
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFcca253)),
                    ),
                  ),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Senha *',
                    hintText: 'Mínimo de 6 caracteres',
                    hintStyle: TextStyle(color: Colors.white70),
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFcca253)),
                    ),
                  ),
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
                Stack(
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Permite apenas dígitos
                      ],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Peso (opcional)',
                        hintText: 'Ex.: 71.2',
                        hintStyle: TextStyle(color: Colors.white70),
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFcca253)),
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 10, // Ajuste de posição
                      top:
                          20, // Alinhamento vertical, ajustado conforme necessário
                      child: Text(
                        'kg',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Permite apenas dígitos
                      ],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Altura (opcional)',
                        hintText: 'Ex.: 1.75',
                        hintStyle: TextStyle(color: Colors.white70),
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFcca253)),
                        ),
                      ),
                    ),
                    const Positioned(
                      right: 10, // Ajuste de posição
                      top:
                          20, // Alinhamento vertical, ajustado conforme necessário
                      child: Text(
                        'm',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFcca253),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
