import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/services/auth.service.dart';
import 'package:daily_training_flutter/services/users.service.dart';
import 'package:daily_training_flutter/widgets/CustomTextField.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({Key? key}) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  // Controllers para os campos editáveis
  // bool _hasChangedUserData = false;
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  User? userData;
  bool _isLoading = true;
  bool _isUpdating = false;
  final ValueNotifier<bool> _hasChangedUserData = ValueNotifier<bool>(false);
  // bool _isEditingTextField = false;
  final ValueNotifier<bool> _isEditingTextField = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingActionButton = ValueNotifier<bool>(false);
  final ValueNotifier<Uint8List?> newProfileImage =
      ValueNotifier<Uint8List?>(null);

  // Dados de exemplo do histórico
  List<FlSpot> _bmiData = [];
  List<FlSpot> _heightData = [];
  List<FlSpot> _weightData = [];

  @override
  void initState() {
    super.initState();
    _bmiController.addListener(verifyIfHasChangedUserData);
    newProfileImage.addListener(verifyIfHasChangedUserData);
    _nameController.addListener(verifyIfHasChangedUserData);
    _emailController.addListener(verifyIfHasChangedUserData);

    _weightController.addListener(_formatWeightDynamically);
    _weightController.addListener(verifyIfHasChangedUserData);

    _heightController.addListener(_formatHeightDynamically);
    _heightController.addListener(verifyIfHasChangedUserData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      verifyIfHasChangedUserData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bmiController.removeListener(verifyIfHasChangedUserData);
    newProfileImage.removeListener(verifyIfHasChangedUserData);
    _nameController.removeListener(verifyIfHasChangedUserData);
    _emailController.removeListener(verifyIfHasChangedUserData);

    _weightController.removeListener(_formatWeightDynamically);
    _weightController.removeListener(verifyIfHasChangedUserData);

    _heightController.removeListener(_formatHeightDynamically);
    _heightController.removeListener(verifyIfHasChangedUserData);

    _bmiController.dispose();
    newProfileImage.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
  }

  void verifyIfHasChangedUserData() {
    final hasChanged = newProfileImage.value != null ||
        _nameController.text != userData?.name ||
        _emailController.text != userData?.email ||
        _bmiController.text != userData?.bmi.toString() ||
        _heightController.text != userData?.height.toString() ||
        _weightController.text != userData?.weight.toString();

    if (_hasChangedUserData.value != hasChanged) {
      setState(() {
        _hasChangedUserData.value = hasChanged;
      });
    }
  }

  // Método para carregar dados iniciais do usuário
  Future<void> _initializeData() async {
    try {
      userData = await UsersService.getUserData();

      // Busca dos dados do gráfico
      setState(() {
        _weightData = userData?.userLogs?.weightLogs
                ?.asMap()
                .map((index, data) =>
                    MapEntry(index, FlSpot(index.toDouble(), data.value!)))
                .values
                .toList() ??
            [];
        _bmiData = userData?.userLogs?.bmiLogs
                ?.asMap()
                .map((index, data) =>
                    MapEntry(index, FlSpot(index.toDouble(), data.value!)))
                .values
                .toList() ??
            [];
        _heightData = userData?.userLogs?.heightLogs
                ?.asMap()
                .map((index, data) =>
                    MapEntry(index, FlSpot(index.toDouble(), data.value!)))
                .values
                .toList() ??
            [];
      });

      if (mounted) {
        // Simulação de carregamento de dados da API
        setState(() {
          _nameController.text = userData!.name!;
          _emailController.text = userData!.email!;
          _bmiController.text = userData!.bmi!.toString();
          _heightController.text = userData!.height!.toString();
          _weightController.text = userData!.weight!.toStringAsFixed(1);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao buscar dados')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  setMessage(String message, [bool error = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        message,
        style: TextStyle(
          color: error ? AllColors.red : AllColors.white,
        ),
      )),
    );
  }

  void _setDefaultValueOnFields() {
    setState(() {
      newProfileImage.value = null;
      _isEditingTextField.value = false;
      _isEditingActionButton.value = false;
      _nameController.text = userData!.name!;
      _emailController.text = userData!.email!;
      _bmiController.text = userData!.bmi!.toString();
      _heightController.text = userData!.height!.toString();
      _weightController.text = userData!.weight!.toString();
    });
  }

  void _changeEditingForTrue() {
    setState(() {
      _isEditingTextField.value = true;
      _isEditingActionButton.value = true;
    });
  }

  void _changeEditingForFalse([bool skipDialog = false]) {
    if (newProfileImage.value != null ||
        _nameController.text != userData!.name ||
        _emailController.text != userData!.email ||
        _bmiController.text != userData!.bmi.toString() ||
        _heightController.text != userData!.height.toString() ||
        _weightController.text != userData!.weight.toString()) {
      if (skipDialog == false) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: AllColors.background,
              title: const Text(
                'Descartar alterações?',
                style: TextStyle(color: AllColors.text),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AllColors.red,
                      ),
                      backgroundColor: AllColors.red,
                    ),
                    child: const Icon(
                      size: 18,
                      Icons.close,
                      color: AllColors.white,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _setDefaultValueOnFields();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AllColors.green,
                      ),
                      backgroundColor: AllColors.green,
                    ),
                    child: const Icon(
                      size: 18,
                      Icons.check,
                      color: AllColors.white,
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
    } else {
      _setDefaultValueOnFields();
    }
  }

  // Método para alterar os dados do usuário
  void _updateUserData() async {
    try {
      setState(() {
        _isUpdating = true;
      });

      final usersService = UsersService();
      if (_nameController.text != userData!.name ||
          _emailController.text != userData!.email ||
          _bmiController.text != userData!.bmi.toString() ||
          _heightController.text != userData!.height.toString() ||
          _weightController.text != userData!.weight.toString()) {
        final updatedData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'weight': double.tryParse(_weightController.text),
          'height': double.tryParse(_heightController.text),
        };
        await usersService.update(userData!.id!, updatedData);
      }

      if (newProfileImage.value != null) {
        await usersService.updateProfileImage(
            userData!.id, newProfileImage.value!);
      }

      await UsersService.setUserData(userData!.id!);
      Navigator.pushNamed(context, '/edit-user');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar dados')),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Método para redefinir senha
  void _resetPassword() async {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController oldPasswordController =
            TextEditingController();
        final TextEditingController newPasswordController =
            TextEditingController();
        final TextEditingController confirmPasswordController =
            TextEditingController();

        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha Antiga'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirmar Nova Senha'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text == '' ||
                    confirmPasswordController.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Preencha os campos corretamente',
                        style: TextStyle(color: AllColors.red),
                      ),
                    ),
                  );
                  return;
                } else if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('As senhas não coincidem')),
                  );
                  return;
                }
                try {
                  // await AuthService.resetPassword(
                  //   oldPassword: oldPasswordController.text,
                  //   newPassword: newPasswordController.text,
                  // );

                  await UsersService.setUserData(userData!.id!);
                  Navigator.pushNamed(context, '/edit-user');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Senha redefinida com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao redefinir senha')),
                  );
                }
              },
              child: const Text('Redefinir'),
            ),
          ],
        );
      },
    );
  }

  void _uploadProfileImage() async {
    try {
      final picker = ImagePicker();

      final ImageSource? source = await showModalBottomSheet<ImageSource>(
          backgroundColor: AllColors.background,
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(
                      'Tirar Foto',
                      style: TextStyle(color: AllColors.text),
                    ),
                    leading: const Icon(
                      Icons.camera,
                      color: AllColors.white,
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    title: const Text(
                      'Escolher da Galeria',
                      style: TextStyle(color: AllColors.text),
                    ),
                    leading: const Icon(
                      Icons.photo_library,
                      color: AllColors.white,
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            );
          });

      if (source == null) return;

      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        Uint8List? imageBytes;

        if (kIsWeb) {
          imageBytes = await pickedFile.readAsBytes();
        } else {
          imageBytes = await File(pickedFile.path).readAsBytes();
        }

        // Atualiza diretamente o ValueNotifier
        setState(() {
          _changeEditingForTrue();
          newProfileImage.value = imageBytes;
        });
      }
    } catch (e) {
      setMessage('Erro ao carregar imagem', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AllColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AllColors.gold),
        ),
      );
    }

    String? userName = userData?.name;
    String? userImageUrl = userData?.profileImagePath;
    final decodedUserImage =
        userImageUrl != null ? base64Decode(userImageUrl) : null;

    return Sidebar(
      title: 'Editar Perfil',
      body: Center(
        child: Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                // Seção de imagem de perfil
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 61,
                        backgroundColor: AllColors.gold,
                        child: ValueListenableBuilder<Uint8List?>(
                          valueListenable: newProfileImage,
                          builder: (context, imageBytes, child) {
                            if (imageBytes != null) {
                              // Exibe a nova imagem carregada
                              return CircleAvatar(
                                radius: 60,
                                backgroundImage: MemoryImage(imageBytes),
                              );
                            } else if (decodedUserImage != null) {
                              // Exibe a imagem do perfil original
                              return CircleAvatar(
                                radius: 60,
                                backgroundImage: MemoryImage(decodedUserImage),
                              );
                            } else {
                              // Exibe a inicial do nome do usuário
                              return CircleAvatar(
                                radius: 60,
                                backgroundColor: AllColors.background,
                                child: Text(
                                  (userName?.isNotEmpty == true
                                      ? userName![0].toUpperCase()
                                      : "?"),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: AllColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: ValueListenableBuilder<Uint8List?>(
                          valueListenable: newProfileImage,
                          builder: (context, hasNewProfileImage, child) {
                            return InkWell(
                              // onTap: _uploadProfileImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasNewProfileImage == null
                                      ? AllColors.gold
                                      : AllColors.red,
                                ),
                                child: IconButton(
                                  onPressed: hasNewProfileImage == null
                                      ? _uploadProfileImage
                                      : () {
                                          setState(() {
                                            newProfileImage.value = null;
                                          });
                                          const skipDialog = true;
                                          _changeEditingForFalse(skipDialog);
                                        },
                                  icon: Icon(
                                    size: 16,
                                    hasNewProfileImage == null
                                        ? Icons.camera_alt
                                        : Icons.close,
                                    color: AllColors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Campos de edição
                CustomTextField(
                  label: 'Nome',
                  hint: _nameController.text,
                  controller: _nameController,
                  enabled: _isEditingTextField,
                  style: const TextStyle(color: AllColors.white, fontSize: 12),
                ),
                CustomTextField(
                  label: 'Email',
                  hint: _emailController.text,
                  controller: _emailController,
                  enabled: _isEditingTextField,
                  style: const TextStyle(color: AllColors.white, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: CustomTextField(
                        suffix: 'm',
                        isNumeric: true,
                        label: 'Altura',
                        hint: _heightController.text,
                        controller: _heightController,
                        enabled: _isEditingTextField,
                        style: TextStyle(
                            color: _isEditingTextField.value
                                ? AllColors.red
                                : AllColors.white,
                            fontSize: 10),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: CustomTextField(
                        label: 'IMC',
                        hint: _bmiController.text,
                        controller: _bmiController,
                        enabled: ValueNotifier<bool>(false),
                        style: const TextStyle(
                            color: AllColors.white, fontSize: 10),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: CustomTextField(
                        suffix: 'kg',
                        label: 'Peso',
                        isNumeric: true,
                        hint: _weightController.text,
                        controller: _weightController,
                        enabled: _isEditingTextField,
                        style: const TextStyle(
                            color: AllColors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                // Botões de ação de edição dos dados
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                _buildActionButtons(),
                Divider(height: MediaQuery.of(context).size.height * 0.05),
                // Gráfico interativo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Histórico de Peso, Altura e IMC',
                      style: TextStyle(
                        fontSize: 16,
                        color: AllColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _selectedGraphType,
                      builder: (context, selectedGraphType, child) {
                        return DropdownButton<String>(
                          dropdownColor: AllColors.background,
                          value:
                              selectedGraphType, // Agora usa o valor da variável diretamente
                          onChanged: (value) {
                            setState(() {
                              _selectedGraphType.value =
                                  value!; // Atualiza o valor do gráfico
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'bmi',
                              child: Text(
                                'IMC',
                                style: TextStyle(
                                    fontSize: 12, color: AllColors.text),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'weight',
                              child: Text(
                                'Peso',
                                style: TextStyle(
                                    fontSize: 12, color: AllColors.text),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'height',
                              child: Text(
                                'Altura',
                                style: TextStyle(
                                    fontSize: 12, color: AllColors.text),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ValueListenableBuilder<String>(
                    valueListenable: _selectedGraphType,
                    builder: (context, selectedGraphType, child) {
                      // A lógica de renderização do gráfico depende do tipo selecionado
                      List<FlSpot> data;
                      if (selectedGraphType == 'weight') {
                        data = _weightData;
                      } else if (selectedGraphType == 'height') {
                        data = _heightData;
                      } else {
                        data = _bmiData;
                      }

                      return _weightData.isEmpty &&
                              _bmiData.isEmpty &&
                              _heightData.isEmpty
                          ? const Center(
                              child: Text(
                                'Não há histórico de alterações',
                                style: TextStyle(
                                    fontSize: 14, color: AllColors.text),
                              ),
                            )
                          : LineChart(_buildLineChart(
                              selectedGraphType, data)); // Redesenha o gráfico
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isUpdating) {
      return const Scaffold(
        backgroundColor: AllColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AllColors.gold),
        ),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: _isEditingActionButton,
      builder: (context, isEditing, child) {
        if (isEditing) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _changeEditingForFalse,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AllColors.red,
                  ),
                  padding: const EdgeInsets.all(2),
                  backgroundColor: AllColors.transparent,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 12, color: AllColors.red),
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<bool>(
                valueListenable: _hasChangedUserData,
                builder: (context, hasChanged, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor:
                          hasChanged ? AllColors.gold : AllColors.softGold,
                      foregroundColor:
                          hasChanged ? AllColors.white : AllColors.softWhite,
                    ),
                    onPressed: hasChanged ? _updateUserData : () {},
                    child: const Text(
                      'Salvar Alterações',
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _changeEditingForTrue,
                child: const Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: AllColors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Editar',
                      style: TextStyle(fontSize: 12, color: AllColors.gold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: _resetPassword,
                child: const Text(
                  'Redefinir Senha',
                  style: TextStyle(
                    fontSize: 12,
                    decorationThickness: 2,
                    color: AllColors.gold,
                    decorationColor: AllColors.gold, // Cor do sublinhado
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  // Configurações do gráfico
  final ValueNotifier<String> _selectedGraphType =
      ValueNotifier<String>('weight');

  LineChartData _buildLineChart(String selectedGraphType, List<FlSpot> data) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 1,
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          barWidth: 3,
          spots: data,
          isCurved: true,
          isStrokeCapRound: true,
          color: AllColors.gold,
          belowBarData: BarAreaData(
            show: true,
          ),
        ),
      ],
      borderData: FlBorderData(
        show: true,
        border: const Border(
          left: BorderSide(color: AllColors.white, width: 1),
          bottom: BorderSide(color: AllColors.white, width: 1),
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              selectedGraphType == 'weight'
                  ? value.toStringAsFixed(1)
                  : value.toStringAsFixed(2),
              style: const TextStyle(color: AllColors.text, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  void _formatWeightDynamically() {
    var currentText = _weightController.text;
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
