import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  User? userData;
  bool _isLoading = true;

  // Estado da imagem de perfil
  String? _profileImageUrl;

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
    if (!mounted) return;

    try {
      userData = await AuthService.getUserData();

      // Simulação de carregamento de dados da API
      setState(() {
        _isLoading = false;
        _nameController.text = userData!.name!;
        _emailController.text = userData!.email!;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao buscar dados')),
        );
      }
    }
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
    // Chama a service de atualização
    print('Atualizando dados do usuário...');
  }

  // Método para redefinir senha
  void _resetPassword() {
    // Chama a service de redefinição de senha
    print('Redefinindo senha...');
  }

  // Método para alterar a imagem do perfil
  void _updateProfileImage() {
    // Chama a service de alteração de imagem
    print('Alterando imagem de perfil...');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AllColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AllColors.gold,
          ),
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
                        radius: 60,
                        backgroundColor: AllColors.transparent,
                        child: decodedUserImage == null
                            ? Text(
                                (userName?.isNotEmpty == true
                                    ? userName![0].toUpperCase()
                                    : "?"),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: AllColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : ClipOval(
                                child: Image.memory(
                                  decodedUserImage,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text(
                                    (userName?.isNotEmpty == true
                                        ? userName![0].toUpperCase()
                                        : "?"),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: AllColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),
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
                              Icons.camera_alt,
                              color: Colors.white,
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
                ),
                CustomTextField(
                  label: 'Email',
                  hint: _emailController.text,
                  controller: _emailController,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _updateUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AllColors.gold,
                    foregroundColor: AllColors.white,
                  ),
                  child: const Text(
                    'Salvar Alterações',
                    style: TextStyle(
                      color: AllColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Redefinir senha
                TextButton(
                  onPressed: _resetPassword,
                  child: const Text(
                    'Redefinir Senha',
                    style: TextStyle(color: AllColors.gold),
                  ),
                ),
                const Divider(height: 30),
                // Gráfico interativo
                const Text(
                  'Histórico de Peso, Altura e IMC',
                  style: TextStyle(
                    fontSize: 18,
                    color: AllColors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  dropdownColor: AllColors.background,
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
                          style: TextStyle(color: AllColors.text),
                        )),
                    DropdownMenuItem(
                        value: 'weight',
                        child: Text(
                          'Peso',
                          style: TextStyle(color: AllColors.text),
                        )),
                    DropdownMenuItem(
                        value: 'height',
                        child: Text(
                          'Altura',
                          style: TextStyle(color: AllColors.text),
                        )),
                  ],
                ),
                const SizedBox(height: 10),
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
