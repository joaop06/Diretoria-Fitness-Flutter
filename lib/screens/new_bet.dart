import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/utils/Date.dart';
import 'package:daily_training_flutter/widgets/DateRangePicker.dart';
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';
import 'package:daily_training_flutter/widgets/CustomTextFormField.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';

class NewBetScreen extends StatefulWidget {
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
              content: Text(betsProvider.errorMessage ?? 'Erro ao criar aposta',
                  style: const TextStyle(color: Colors.red))),
        );
      }

      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Nova Aposta',
      body: Center(
        child: Container(
          constraints: BoxConstraints(minWidth: 500, maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  DateRangePicker(
                    finalDateController: _finalDateController,
                    initialDateController: _initialDateController,
                  ),
                  const SizedBox(height: 24),
                  _buildNumberField(
                    label: "Faltas Permitidas",
                    controller: _faultsAllowedController,
                  ),
                  _buildMinimumPenaltyField(
                    label: "Valor Mínimo da Penalidade",
                    controller: _minimumPenaltyAmountController,
                  ),
                  const SizedBox(height: 24),
                  CustomElevatedButton(
                      onPressed: _isLoading ? null : _createBet,
                      isLoading: _isLoading,
                      backgroundColor: AllColors.gold,
                      foregroundColor: Colors.black,
                      child: const Text(
                        "Agendar Aposta",
                        style: TextStyle(color: Colors.white),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: Date.now(),
      firstDate: Date.year(2000),
      lastDate: Date.year(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AllColors.orange, // Cor do botão de seleção
              onPrimary: Colors.white, // Cor do texto do botão
              surface: AllColors.background, // Cor de fundo
              onSurface: Colors.white, // Cor do texto no fundo
            ),
            dialogBackgroundColor: const Color(0xFF1e1c1b),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      // Formata a data selecionada no formato "dd/MM/yyyy"
      controller.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    }
  }

  Widget _buildDateField({
    required String hint,
    required String label,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        readOnly: true,
        controller: controller,
        onTap: () => _pickDate(context, controller),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: const Color(0xFF1e1c1b),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color.fromARGB(255, 222, 159, 42)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Por favor, selecione a $label.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMinimumPenaltyField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          CurrencyInputFormatter(
            leadingSymbol: 'R\$ ',
            useSymbolPadding: true,
            thousandSeparator: ThousandSeparator.Period,

            // decimalSeparator: ThousandSeparator.Comma,
          ),
        ],
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: "R\$ 30,00",
          hintStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: const Color(0xFF1e1c1b),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color.fromARGB(255, 222, 159, 42)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Por favor, insira $label.";
          }
          // Retira a máscara para validar o número
          final unmaskedValue = toNumericString(value, allowHyphen: false);
          if (double.tryParse(unmaskedValue) == null) {
            return "Por favor, insira um número válido.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          hintText: "Ex.: 2",
          hintStyle: const TextStyle(color: Colors.white30),
          filled: true,
          fillColor: const Color(0xFF1e1c1b),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Color.fromARGB(255, 222, 159, 42)),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Por favor, insira $label.";
          }
          if (double.tryParse(value) == null) {
            return "Por favor, insira um número válido.";
          }
          return null;
        },
      ),
    );
  }
}
