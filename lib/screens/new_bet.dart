import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:daily_training_flutter/widgets/CustomTextField.dart';
import 'package:daily_training_flutter/widgets/DateRangePicker.dart';
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';

class NewBetScreen extends StatefulWidget {
  const NewBetScreen({super.key});

  @override
  _NewBetScreenScreenState createState() => _NewBetScreenScreenState();
}

class _NewBetScreenScreenState extends State<NewBetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _initialDateController = TextEditingController();
  final TextEditingController _finalDateController = TextEditingController();
  final TextEditingController _faultsAllowedController =
      TextEditingController();
  final TextEditingController _minimumPenaltyAmountController =
      TextEditingController();

  @override
  void dispose() {
    _initialDateController.dispose();
    _finalDateController.dispose();
    _faultsAllowedController.dispose();
    _minimumPenaltyAmountController.dispose();
    super.dispose();
  }

  String convertDate(String inputDate) {
    final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
    final DateFormat outputFormat = DateFormat('yyyy-MM-dd');

    final DateTime parsedDate = inputFormat.parse(inputDate);
    return outputFormat.format(parsedDate);
  }

  double convertMoney(String inputMoney) {
    return double.parse(_minimumPenaltyAmountController.text
        .replaceAll('R\$ ', '')
        .replaceAll(',', '.'));
  }

  var _isLoading = false;
  void _createBet() async {
    try {
      _isLoading = true;
      final betsProvider = Provider.of<BetsProvider>(context, listen: false);

      if (_formKey.currentState?.validate() ?? false) {
        final trainingBet = {
          "initialDate": convertDate(_initialDateController.text),
          "finalDate": convertDate(_finalDateController.text),
          "faultsAllowed": int.parse(_faultsAllowedController.text),
          "minimumPenaltyAmount":
              convertMoney(_minimumPenaltyAmountController.text),
        };

        await betsProvider.create(trainingBet);

        if (betsProvider.errorMessage == null) {
          // Mostra uma mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
              'Aposta criada com sucesso!',
              style: TextStyle(color: Colors.green),
            )),
          );

          // Redireciona para a tela de login
          Navigator.pushReplacementNamed(context, '/bets');
        } else {
          // Exibe o erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    betsProvider.errorMessage ?? 'Erro ao criar aposta',
                    style: const TextStyle(color: Colors.red))),
          );
        }

        _isLoading = false;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Nova Aposta',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(minWidth: 500, maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DateRangePicker(
                    label: 'Período da Aposta',
                    finalDateController: _finalDateController,
                    initialDateController: _initialDateController,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  CustomTextField(
                    hint: 'Ex.: 2',
                    isNumeric: true,
                    label: 'Faltas Permitidas',
                    controller: _faultsAllowedController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira um valor válido";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  CustomTextField(
                    isCurrency: true,
                    // hint: "R\$ 30,00",
                    label: 'Valor da Penalidade (R\$)',
                    controller: _minimumPenaltyAmountController,
                    hintStyle: const TextStyle(color: Colors.white30),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, insira um valor válido";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  CustomElevatedButton(
                    isLoading: _isLoading,
                    foregroundColor: Colors.black,
                    backgroundColor: AllColors.gold,
                    onPressed: _isLoading ? null : _createBet,
                    child: const Text(
                      "Agendar Aposta",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
