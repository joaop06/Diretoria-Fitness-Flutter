import 'dart:convert';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/services/ranking.service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      // Busca os dados da classificação
      await Provider.of<RankingProvider>(context, listen: false).getRanking();

      // Update loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

    if (rankingProvider.isLoading) {
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

    return Sidebar(
      title: 'Classificação de Usuários',
      body: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        color: const Color(0xFF282624),
        padding: const EdgeInsets.all(16.0),
        child: rankingData!.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: AllColors.gold,
                ),
              )
            : ListView.builder(
                itemCount: rankingData?.length,
                itemBuilder: (context, index) {
                  final Ranking item = rankingData![index];
                  return _buildRankingCard(item, index + 1);
                },
              ),
      ),
    );
  }

  // Card de exibição do ranking
  Widget _buildRankingCard(Ranking item, int rank) {
    final userInfo = item.user;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.005,
        // maxHeight: MediaQuery.of(context).size.height * 0.3,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AllColors.gold,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: _buildStat("Vitórias", userInfo.wins),
                            ),
                            Flexible(
                              child: _buildStat("Derrotas", userInfo.losses),
                            ),
                            Flexible(
                              child: _buildStat("Faltas", userInfo.totalFaults),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
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
                decodedImage,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: label == 'Vitórias'
                    ? Colors.green.shade800
                    : label == 'Derrotas'
                        ? Colors.red.shade800
                        : Colors.white70,
                fontSize: MediaQuery.of(context).size.width * 0.028,
              ),
            ),
          ),
          Center(
            child: Text(
              "$value",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.022,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
