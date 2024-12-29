import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/services/ranking.service.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:daily_training_flutter/providers/ranking.provider.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  List<Ranking>? rankingData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // BackButtonInterceptor.add(backButtonInterceptor);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    // BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushNamed(context, '/bets');
    return true;
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      // Busca os dados da classificação
      await Provider.of<RankingProvider>(context, listen: false).getRanking();
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao buscar dados')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final rankingProvider = context.watch<RankingProvider>();
    rankingData = rankingProvider.ranking;

    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF1e1c1b),
        body: const Center(
          child: CircularProgressIndicator(
            color: AllColors.gold,
          ),
        ),
      );
    }

    // Separar os 3 primeiros colocados e o restante
    final podium = rankingData!.take(3).toList();
    final others = rankingData!.skip(3).toList();

    return Sidebar(
      title: 'Classificação de Usuários',
      body: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        color: AllColors.background,
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exibição do pódio
            if (podium.isNotEmpty) _buildPodium(podium),
            const SizedBox(height: 20),

            // Listagem do 4º em diante
            Expanded(
              child: ListView.builder(
                itemCount: others.length,
                itemBuilder: (context, index) {
                  final Ranking item = others[index];
                  return _buildRankingCard(item, index + 4);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para o pódio
  Widget _buildPodium(List<Ranking> podium) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Degraus do pódio
        LayoutBuilder(
          builder: (context, constraints) {
            double stepWidth = constraints.maxWidth /
                3; // Ajuste proporcional à largura disponível
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 2º colocado - Degrau esquerdo
                if (podium.length > 1)
                  _buildPodiumStep(podium[1], 2,
                      heightMultiplier: 1.1, stepWidth: stepWidth),

                // 1º colocado - Degrau central
                if (podium.isNotEmpty)
                  _buildPodiumStep(podium[0], 1,
                      heightMultiplier: 1.4, stepWidth: stepWidth),

                // 3º colocado - Degrau direito
                if (podium.length > 2)
                  _buildPodiumStep(podium[2], 3,
                      heightMultiplier: 0.8, stepWidth: stepWidth),
              ],
            );
          },
        ),
      ],
    );
  }

// Construção de um degrau do pódio
  Widget _buildPodiumStep(Ranking item, int rank,
      {double heightMultiplier = 1.0, double stepWidth = 100.0}) {
    final userInfo = item.user;
    final imagePath = item.user.profileImagePath;
    final decodedImage = imagePath != null ? base64Decode(imagePath) : null;

    final spacingBetweenStatistics = SizedBox(
      width: MediaQuery.of(context).size.width * 0.03,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar do usuário com borda colorida
        CircleAvatar(
          radius: stepWidth *
              0.3, // Ajusta o tamanho do avatar de acordo com a largura disponível
          backgroundColor: rank == 1
              ? const Color.fromARGB(255, 255, 215, 0) // Ouro
              : rank == 2
                  ? const Color.fromARGB(255, 192, 192, 192) // Prata
                  : const Color.fromARGB(255, 205, 127, 50), // Bronze
          child: CircleAvatar(
            radius: stepWidth * 0.27, // Ajusta o tamanho do avatar interno
            backgroundColor: AllColors.softBlack,
            child: decodedImage != null
                ? ClipOval(
                    child: Image.memory(
                      width: 100,
                      height: 100,
                      decodedImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Column(
                        children: [
                          const Icon(
                            Icons.error,
                            color: AllColors.red,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                          )
                        ],
                      ),
                    ),
                  )
                : Text(
                    item.user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AllColors.white),
                  ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          "${item.score} pts",
          style: TextStyle(
            color: AllColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width > 550
                ? 20
                : MediaQuery.of(context).size.width * 0.035,
          ),
        ),
        // Informações do usuário no degrau
        Container(
          width: stepWidth,
          color: AllColors.backgroundPodium,
          height:
              (MediaQuery.of(context).size.height * 0.08) * heightMultiplier,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: (MediaQuery.of(context).size.height * 0.005) *
                    heightMultiplier,
              ),
              Text(
                userInfo.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height * 0.01) *
                    heightMultiplier,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Vitórias",
                        style: TextStyle(
                          fontSize: 8,
                          color: AllColors.green,
                        ),
                      ),
                      Text(
                        "${item.user.wins}",
                        style: const TextStyle(
                          fontSize: 8,
                          color: AllColors.green,
                        ),
                      ),
                    ],
                  ),
                  spacingBetweenStatistics,
                  Column(
                    children: [
                      const Text(
                        "Derrotas",
                        style: TextStyle(
                          fontSize: 8,
                          color: AllColors.red,
                        ),
                      ),
                      Text(
                        "${item.user.losses}",
                        style: const TextStyle(
                          fontSize: 8,
                          color: AllColors.red,
                        ),
                      ),
                    ],
                  ),
                  spacingBetweenStatistics,
                  Column(
                    children: [
                      const Text(
                        "Faltas",
                        style: TextStyle(
                          fontSize: 8,
                          color: AllColors.softWhite,
                        ),
                      ),
                      Text(
                        "${item.user.totalFaults}",
                        style: const TextStyle(
                          fontSize: 8,
                          color: AllColors.softWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Card de exibição do ranking
  Widget _buildRankingCard(Ranking item, int rank) {
    final userInfo = item.user;
    final spacingBetweenStatistics = SizedBox(
      width: MediaQuery.of(context).size.width * 0.03,
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.005,
      ),
      child: Card(
        color: const Color(0xFF1e1c1b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userInfo.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.07,
                    ),
                    child: Text(
                      "${item.score} pts",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AllColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          _buildRankBadge(rank),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.02,
                          ),
                          _buildProfileImage(userInfo.profileImagePath),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStat("Vitórias", userInfo.wins),
                            spacingBetweenStatistics,
                            _buildStat("Derrotas", userInfo.losses),
                            spacingBetweenStatistics,
                            _buildStat("Faltas", userInfo.totalFaults),
                            spacingBetweenStatistics,
                            _buildStat("Treinos", userInfo.totalTrainingDays),
                            spacingBetweenStatistics,
                            _buildStat(
                              "Participações",
                              userInfo.totalParticipations,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Badge com a posição do ranking
  Widget _buildRankBadge(int rank) {
    return CircleAvatar(
      backgroundColor: rank == 1
          ? const Color.fromARGB(255, 255, 215, 0)
          : rank == 2
              ? const Color.fromARGB(255, 206, 206, 206)
              : rank == 3
                  ? const Color.fromARGB(255, 205, 127, 50)
                  : const Color.fromARGB(255, 128, 128, 128),
      radius: MediaQuery.of(context).size.width * 0.022,
      child: Text(
        "$rankº",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.width * 0.02,
        ),
      ),
    );
  }

  // Exibe a imagem do perfil ou um ícone padrão
  Widget _buildProfileImage(String? profileImagePath) {
    final decodedImage =
        profileImagePath != null ? base64Decode(profileImagePath) : null;

    return CircleAvatar(
      radius: MediaQuery.of(context).size.width * 0.05,
      backgroundColor: const Color(0xFF282624),
      child: decodedImage == null
          ? Icon(
              Icons.person,
              color: AllColors.gold,
              size: MediaQuery.of(context).size.width * 0.035,
            )
          : ClipOval(
              child: Image.memory(
                width: 100,
                height: 100,
                decodedImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Column(
                  children: [
                    Icon(
                      Icons.person,
                      color: AllColors.gold,
                      size: MediaQuery.of(context).size.width * 0.035,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // Widget para exibir estatísticas (Vitórias, Derrotas, Faltas)
  Widget _buildStat(String label, int value) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: label == 'Vitórias'
                    ? AllColors.green
                    : label == 'Derrotas'
                        ? AllColors.red
                        : AllColors.softWhite,
              ),
            ),
          ),
          Center(
            child: Text(
              "$value",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
