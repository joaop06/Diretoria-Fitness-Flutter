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
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  User? userData;
  bool _isLoading = true;
  String? _profileImageUrl;
  bool _isEditingTextField = false;
  final ValueNotifier<bool> _isEditingActionButton = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasNewProfileImage = ValueNotifier<bool>(false);
  final ValueNotifier<Uint8List?> newProfileImage =
      ValueNotifier<Uint8List?>(null);

  // Dados de exemplo do histórico
  List<FlSpot> _bmiData = [];
  List<FlSpot> _heightData = [];
  List<FlSpot> _weightData = [];

  // Tipo de dado selecionado para o gráfico
  String _selectedGraphType = 'weight';

  @override
  void initState() {
    super.initState();
    _fetchGraphData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  // Método para carregar dados iniciais do usuário
  Future<void> _initializeData() async {
    try {
      userData = await UsersService.getUserData();

      if (mounted) {
        // Simulação de carregamento de dados da API
        setState(() {
          _nameController.text = userData!.name!;
          _emailController.text = userData!.email!;
          _bmiController.text = userData!.bmi!.toString();
          _heightController.text = userData!.height!.toString();
          _weightController.text = userData!.weight!.toString();
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

  void _toggleEditing() {
    setState(() {
      _isEditingTextField = !_isEditingTextField;
      _isEditingActionButton.value = !_isEditingActionButton.value;
    });
  }

  // Método para buscar dados do gráfico (simulação)
  void _fetchGraphData() {
    setState(() {
      // Dados de histórico (exemplo)
      _weightData = [
        const FlSpot(0, 70),
        const FlSpot(1, 71),
        const FlSpot(2, 72),
      ];
      _bmiData = [
        const FlSpot(0, 22.9),
        const FlSpot(1, 23.1),
        const FlSpot(2, 23.3),
      ];
      _heightData = [
        const FlSpot(0, 1.75),
        const FlSpot(1, 1.76),
        const FlSpot(2, 1.76),
      ];
    });
  }

  // Método para alterar os dados do usuário
  void _updateUserData() {
    try {
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'weight': double.tryParse(_weightController.text),
        'height': double.tryParse(_heightController.text),
      };
      // await AuthService.updateUserData(updatedData);
      setState(() {
        _isEditingActionButton.value = false;
        _isEditingTextField = !_isEditingTextField;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar dados')),
      );
    }
  }

  // Método para redefinir senha
  void _resetPassword() {
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
                if (newPasswordController.text !=
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
                  Navigator.pop(context);
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

  final ValueNotifier<Uint8List?> profileImage =
      ValueNotifier<Uint8List?>(null);

  void _updateProfileImage() async {
    try {
      final picker = ImagePicker();

      final ImageSource? source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (BuildContext context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Tirar Foto'),
                    leading: const Icon(Icons.camera),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    title: const Text('Escolher da Galeria'),
                    leading: const Icon(Icons.photo_library),
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
          _isEditingTextField = true;
          newProfileImage.value = imageBytes;
          _hasNewProfileImage.value = true;
          _isEditingActionButton.value = true;
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
                      // ValueListenableBuilder<bool>(
                      //   valueListenable: _hasNewProfileImage,
                      //   builder: (context, hasNewProfileImage, child) {
                      //     if (hasNewProfileImage) {
                      //       return Row(
                      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //         children: [
                      //           Positioned(
                      //             bottom: 0,
                      //             left: 0,
                      //             child: InkWell(
                      //               onTap: _updateProfileImage,
                      //               child: Container(
                      //                 decoration: const BoxDecoration(
                      //                   shape: BoxShape.circle,
                      //                   color: AllColors.gold,
                      //                 ),
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: const Icon(
                      //                   size: 16,
                      //                   Icons.home_work,
                      //                   color: AllColors.white,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //           Positioned(
                      //             bottom: 0,
                      //             right: 0,
                      //             child: InkWell(
                      //               onTap: _updateProfileImage,
                      //               child: Container(
                      //                 decoration: const BoxDecoration(
                      //                   shape: BoxShape.circle,
                      //                   color: AllColors.red,
                      //                 ),
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: const Icon(
                      //                   size: 16,
                      //                   Icons.close,
                      //                   color: AllColors.white,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     } else {
                      //       return Row(
                      //         mainAxisAlignment: MainAxisAlignment.end,
                      //         children: [
                      //           Positioned(
                      //             bottom: 0,
                      //             right: 0,
                      //             child: InkWell(
                      //               onTap: _updateProfileImage,
                      //               child: Container(
                      //                 decoration: const BoxDecoration(
                      //                   shape: BoxShape.circle,
                      //                   color: AllColors.gold,
                      //                 ),
                      //                 padding: const EdgeInsets.all(8.0),
                      //                 child: const Icon(
                      //                   size: 16,
                      //                   Icons.camera_alt,
                      //                   color: AllColors.white,
                      //                 ),
                      //               ),
                      //             ),
                      //           ),
                      //         ],
                      //       );
                      //     }
                      //   },
                      // ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _updateProfileImage,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AllColors.gold,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(
                              size: 16,
                              Icons.camera_alt,
                              color: AllColors.white,
                            ),
                          ),
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
                  enabled: _isEditingTextField,
                  controller: _emailController,
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
                        enabled: _isEditingTextField,
                        hint: _heightController.text,
                        controller: _heightController,
                        style: const TextStyle(
                            color: AllColors.white, fontSize: 10),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: CustomTextField(
                        label: 'IMC',
                        enabled: false,
                        hint: _bmiController.text,
                        controller: _bmiController,
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
                        enabled: _isEditingTextField,
                        hint: _weightController.text,
                        controller: _weightController,
                        style: const TextStyle(
                            color: AllColors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                // Botões de ação de edição dos dados
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
                    DropdownButton<String>(
                      dropdownColor: const Color.fromARGB(248, 31, 23, 15),
                      value: _selectedGraphType,
                      onChanged: (value) {
                        setState(() {
                          _selectedGraphType = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                            value: 'bmi',
                            child: Text(
                              'IMC',
                              style: TextStyle(
                                  fontSize: 12, color: AllColors.text),
                            )),
                        DropdownMenuItem(
                            value: 'weight',
                            child: Text(
                              'Peso',
                              style: TextStyle(
                                  fontSize: 12, color: AllColors.text),
                            )),
                        DropdownMenuItem(
                            value: 'height',
                            child: Text(
                              'Altura',
                              style: TextStyle(
                                  fontSize: 12, color: AllColors.text),
                            )),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: LineChart(_buildLineChart()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isEditingActionButton,
      builder: (context, isEditing, child) {
        if (isEditing) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  _toggleEditing();
                  setState(() {
                    _isEditingTextField = false;
                    newProfileImage.value = null;
                    _hasNewProfileImage.value = false;
                    _isEditingActionButton.value = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColors.grey,
                  foregroundColor: AllColors.white,
                ),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColors.gold,
                  foregroundColor: AllColors.white,
                ),
                child: const Text('Salvar Alterações'),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              ElevatedButton(
                onPressed: _toggleEditing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColors.gold,
                  foregroundColor: AllColors.white,
                ),
                child: const Text('Editar'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AllColors.red,
                  foregroundColor: AllColors.white,
                ),
                child: const Text('Redefinir Senha'),
              ),
            ],
          );
        }
      },
    );
  }

  // Configurações do gráfico
  LineChartData _buildLineChart() {
    List<FlSpot> data;
    if (_selectedGraphType == 'weight') {
      data = _weightData;
    } else if (_selectedGraphType == 'height') {
      data = _heightData;
    } else {
      data = _bmiData;
    }

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          barWidth: 3,
          spots: data,
          isCurved: true,
          isStrokeCapRound: true,
          color: AllColors.gold,
          belowBarData: BarAreaData(show: false),
        ),
      ],
      borderData: FlBorderData(show: true),
      titlesData: const FlTitlesData(show: true),
    );
  }
}
