import 'package:daily_training_flutter/services/auth.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';
import 'package:daily_training_flutter/widgets/CustomTextField.dart';
import 'package:daily_training_flutter/widgets/CustomTextFormField.dart';
import 'package:daily_training_flutter/widgets/DateRangePicker.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/Date.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';

class EditBetScreen extends StatefulWidget {
  final String betId;

  const EditBetScreen({Key? key, required this.betId}) : super(key: key);

  @override
  State<EditBetScreen> createState() => _EditBetScreenState();
}

class _EditBetScreenState extends State<EditBetScreen> {
  int? betId;
  Bet? betDetails;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _initialDateController = TextEditingController();
  final TextEditingController _finalDateController = TextEditingController();
  final TextEditingController _faultsAllowedController =
      TextEditingController();
  final TextEditingController _minimumPenaltyAmountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBetData();
  }

  Future<void> _loadBetData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final betsProvider = Provider.of<BetsProvider>(context, listen: false);

      betId = await AuthService.getBetDetailsId();
      if (betId == null) throw Exception('Aposta não informada');

      await betsProvider.getBetDetails(betId);
      betDetails = betsProvider.bets[0];

      _faultsAllowedController.text = betDetails!.faultsAllowed.toString();
      _finalDateController.text = Date(date: betDetails!.finalDate).format();
      _initialDateController.text =
          Date(date: betDetails!.initialDate).format();
      _minimumPenaltyAmountController.text =
          '${betDetails!.minimumPenaltyAmount}';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar detalhes da aposta')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final betsProvider = Provider.of<BetsProvider>(context, listen: false);

    final updatedBet = {
      "initialDate": convertDate(_initialDateController.text),
      "finalDate": convertDate(_finalDateController.text),
      "faultsAllowed": int.parse(_faultsAllowedController.text),
      "minimumPenaltyAmount":
          convertMoney(_minimumPenaltyAmountController.text),
    };

    await betsProvider.update(betId!, updatedBet);

    if (betsProvider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aposta atualizada com sucesso!',
              style: TextStyle(color: Colors.green)),
        ),
      );
      Navigator.pushNamed(context, '/bet-details');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              betsProvider.errorMessage ?? 'Erro ao atualizar a aposta',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _deleteBet() async {
    setState(() => _isLoading = true);

    final betsProvider = Provider.of<BetsProvider>(context, listen: false);

    await betsProvider.delete(betId!);

    if (betsProvider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aposta deletada com sucesso!',
              style: TextStyle(color: Colors.green)),
        ),
      );
      Navigator.pushNamed(context, '/bets');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(betsProvider.errorMessage ?? 'Erro ao deletar a aposta',
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AllColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AllColors.orange,
          ),
        ),
      );
    }

    return Sidebar(
      title: 'Editar Aposta $betId',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Deletar Aposta'),
              content:
                  const Text('Tem certeza que deseja deletar esta aposta?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _deleteBet();
                  },
                  child: const Text('Deletar',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AllColors.gold,
              ),
            )
          : Container(
              color: AllColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DateRangePicker(
                        finalDate: betDetails?.finalDate,
                        initialDate: betDetails?.initialDate,
                        finalDateController: _finalDateController,
                        initialDateController: _initialDateController,
                      ),
                      CustomTextField(
                        isNumeric: true,
                        hint: 'Ex.: 2',
                        label: 'Faltas Permitidas',
                        controller: _faultsAllowedController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor, insira um valor válido";
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        isCurrency: true,
                        hint: "R\$ 30,00",
                        label: 'Valor da Penalidade (R\$)',
                        hintStyle: const TextStyle(color: Colors.white30),
                        controller: _minimumPenaltyAmountController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor, insira um valor válido";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedButton(
                        isLoading: _isLoading,
                        foregroundColor: Colors.black,
                        backgroundColor: AllColors.gold,
                        onPressed: _isLoading ? null : _saveChanges,
                        child: const Text(
                          "Salvar Alterações",
                          style: TextStyle(color: Colors.white),
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
