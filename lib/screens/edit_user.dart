import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({Key? key}) : super(key: key);

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  // Controllers para os campos editáveis
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Estado da imagem de perfil
  String? _profileImageUrl;

  // Dados de exemplo do histórico
  List<FlSpot> _weightData = [];
  List<FlSpot> _heightData = [];
  List<FlSpot> _bmiData = [];

  // Tipo de dado selecionado para o gráfico
  String _selectedGraphType = 'weight';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchGraphData();
  }

  // Método para carregar dados iniciais do usuário
  void _loadUserData() {
    // Simulação de carregamento de dados da API
    setState(() {
      _nameController.text = 'Nome do Usuário';
      _emailController.text = 'email@exemplo.com';
      _profileImageUrl = 'https://via.placeholder.com/150';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de imagem de perfil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _updateProfileImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Campos de edição
              _buildInputField('Nome', _nameController),
              _buildInputField('Email', _emailController),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar Alterações'),
              ),
              const SizedBox(height: 20),
              // Redefinir senha
              TextButton(
                onPressed: _resetPassword,
                child: const Text('Redefinir Senha',
                    style: TextStyle(color: Colors.deepPurple)),
              ),
              const Divider(height: 30),
              // Gráfico interativo
              const Text(
                'Histórico de Peso, Altura e IMC',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedGraphType,
                onChanged: (value) {
                  setState(() {
                    _selectedGraphType = value!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 'weight', child: Text('Peso')),
                  DropdownMenuItem(value: 'height', child: Text('Altura')),
                  DropdownMenuItem(value: 'bmi', child: Text('IMC')),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: LineChart(_buildLineChart()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para campos de entrada
  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
      ],
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
          spots: data,
          isCurved: true,
          color: Colors.deepPurple,
          barWidth: 3,
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: true),
      borderData: FlBorderData(show: true),
    );
  }
}
