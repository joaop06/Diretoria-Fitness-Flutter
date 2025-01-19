import 'dart:async';
import 'package:daily_training_flutter/services/users.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/providers/auth.provider.dart';
import 'package:daily_training_flutter/providers/email.provider.dart';
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';

class VerificationCodeScreen extends StatefulWidget {
  final int? userId;
  final String? email;
  final String? redirectRoute;
  final bool? resendCodeWhenStarting;

  const VerificationCodeScreen({
    super.key,
    this.email,
    this.userId,
    this.redirectRoute,
    this.resendCodeWhenStarting,
  });

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  Timer? _timer;
  bool _isLoading = false;
  int _secondsRemaining = 60;
  bool _resendingCode = false;
  bool _isButtonDisabled = true;
  final _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _startTimer();

    if (widget.email == null || widget.userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(context, widget.redirectRoute ?? '/');
      });
    } else {
      // Adiar a execução de _resendVerificationCode
      if (widget.resendCodeWhenStarting == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _resendVerificationCode();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isButtonDisabled = true;
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;

    final username = parts[0];
    final domain = parts[1];

    final maskedUsername =
        '${username.substring(0, 4)}******${username[username.length - 1]}';
    return '$maskedUsername@$domain';
  }

  void _resendVerificationCode() async {
    try {
      setState(() => _resendingCode = true);
      final emailProvider = Provider.of<EmailProvider>(context, listen: false);

      final result = await emailProvider.resendVerificationCode(widget.userId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
            style: const TextStyle(color: AllColors.text),
          ),
        ),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: AllColors.red),
          ),
        ),
      );
    } finally {
      _startTimer();
      setState(() => _resendingCode = false);
    }
  }

  void _validateVerificationCode() async {
    String code = _controllers.map((controller) => controller.text).join();

    try {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (code == '') {
        throw Exception('Informe o código corretamente');
      }

      final result = await authProvider.verifyVerificationCode(
        widget.userId!,
        int.parse(code),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
            style: const TextStyle(color: AllColors.green),
          ),
        ),
      );

      await UsersService.setUserData(widget.userId!);
      Navigator.pushNamed(context, widget.redirectRoute ?? '/');
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: AllColors.red),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = _maskEmail(widget.email!);

    return Scaffold(
      backgroundColor: AllColors.background,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: AllColors.backgroundSidebar,
        title: const Text(
          'Verificação de E-mail',
          style: TextStyle(fontSize: 16, color: AllColors.gold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AllColors.white),
          onPressed: () {
            Navigator.pushNamed(context, widget.redirectRoute ?? '/');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Informe o Código',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AllColors.text,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'Enviado código de verificação para o e-mail $maskedEmail',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AllColors.text,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            VerificationCodeInput(
              controllers: _controllers,
              validateVerificationCode: _validateVerificationCode,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  isLoading: _isLoading,
                  backgroundColor: AllColors.gold,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  onPressed: _isLoading ? null : _validateVerificationCode,
                  child: const Text(
                    'Confirmar código',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AllColors.text,
                    ),
                  ),
                ),
                TextButton(
                  child: const Text(
                    'Verificar mais tarde',
                    style: TextStyle(
                      fontSize: 12,
                      color: AllColors.gold,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pushNamed(context, widget.redirectRoute ?? '/'),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            TextButton(
              onPressed: _isButtonDisabled ? null : _resendVerificationCode,
              child: _resendingCode
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AllColors.gold,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          !_isButtonDisabled
                              ? 'Reenviar Código de Verificação'
                              : 'Reenviar código em $_secondsRemaining segundos',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: _isButtonDisabled
                                ? AllColors.grey
                                : AllColors.gold,
                          ),
                        ),
                        if (!_isButtonDisabled)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Use um TextPainter para calcular a largura do texto
                              const text = 'Reenviar Código de Verificação';
                              final textPainter = TextPainter(
                                text: const TextSpan(
                                  text: text,
                                  style: TextStyle(fontSize: 12),
                                ),
                                maxLines: 1,
                                textDirection: TextDirection.ltr,
                              )..layout();
                              final textWidth = textPainter.width;

                              return Container(
                                margin: const EdgeInsets.only(top: 1),
                                height: 1, // Espessura do sublinhado
                                width: textWidth, // Largura do texto
                                color: AllColors.gold, // Cor do sublinhado
                              );
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationCodeInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final Function() validateVerificationCode;

  const VerificationCodeInput({
    Key? key,
    required this.controllers,
    required this.validateVerificationCode,
  }) : super(key: key);

  void onCodeChanged(BuildContext context, int index, String value) {
    if (value.length == 1 && index < controllers.length - 1) {
      FocusScope.of(context).nextFocus();
    }
    if (index == controllers.length - 1 && value.length == 1) {
      validateVerificationCode();
    }

    if (value.isEmpty) {
      controllers[index].clear();
      if (controllers[index].text.isEmpty && index > 0) {
        FocusScope.of(context).previousFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controllers.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: SizedBox(
            width: 40,
            height: 80,
            child: TextField(
              maxLength: 1,
              cursorColor: AllColors.gold,
              textAlign: TextAlign.center,
              controller: controllers[index],
              keyboardType: TextInputType.number,
              onChanged: (value) => onCodeChanged(context, index, value),
              style: const TextStyle(color: AllColors.text),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AllColors.gold),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AllColors.softWhite),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AllColors.gold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
