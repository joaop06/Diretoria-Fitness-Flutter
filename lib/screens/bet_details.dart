import 'dart:convert';

import 'package:daily_training_flutter/providers/participants.privider.dart';
import 'package:daily_training_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/services/bets_service.dart';
import 'package:daily_training_flutter/providers/bets_provider.dart';

class BetDetailsScreen extends StatefulWidget {
  const BetDetailsScreen({Key? key}) : super(key: key);

  @override
  _BetDetailsScreenState createState() => _BetDetailsScreenState();
}

class _BetDetailsScreenState extends State<BetDetailsScreen>
    with AutomaticKeepAliveClientMixin {
  int? betId;
  Bet? betDetails;
  bool _isLoading = true;
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
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Extrai o 'id' da aposta
      betId = arguments?['id'];
      if (betId == null) throw Exception('Aposta não informada');

      // Pegando os detalhes da aposta
      final betsProvider = Provider.of<BetsProvider>(context, listen: false);

      await betsProvider.getBetDetails(betId);
      betDetails = betsProvider.bets[0];

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
          const SnackBar(content: Text('Erro ao carregar detalhes da aposta')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF1e1c1b),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFCCA253),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          "Detalhes da Aposta",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1e1c1b),
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/bets');
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: betDetails == null
          ? Container(
              constraints:
                  BoxConstraints(minWidth: MediaQuery.of(context).size.width),
              color: const Color(0xFF282624),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 200),
                        const Text(
                          'Detalhes da aposta não encontrados',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/bets',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text(
                            'Ir para Apostas',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          : Container(
              color: const Color(0xFF282624),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBetInfoCard(betDetails),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildDaysList(betDetails?.betDays ?? []),
                  ),
                ],
              ),
            ),
    );
  }

  // Card com as informações gerais da aposta
  Widget _buildBetInfoCard(Bet? bet) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 500, maxWidth: 800),
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF1e1c1b),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Status:", bet?.status!),
                _buildDetailRow("Duração:", "${bet?.duration} dias"),
                _buildDetailRow(
                    "Data Inicial:",
                    DateFormat('dd/MM/yyyy')
                        .format(bet?.initialDate ?? DateTime.now())),
                _buildDetailRow(
                    "Data Final:",
                    DateFormat('dd/MM/yyyy')
                        .format(bet?.finalDate ?? DateTime.now())),
                _buildDetailRow("Faltas Permitidas:", "${bet?.faultsAllowed}"),
                _buildDetailRow(
                    "Penalidade Mínima:", "R\$ ${bet?.minimumPenaltyAmount}"),
                const SizedBox(height: 25),
                if (bet?.status == 'Agendada')
                  Center(
                      child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 500, maxWidth: 800),
                    child: ElevatedButton(
                      onPressed: () async {
                        final participantData = {
                          'trainingBetId': bet?.id!,
                          'userId': await AuthService.getUserData().id,
                        };
                        final participantsProvider =
                            context.watch<ParticipantsProvider>();

                        await participantsProvider.create(participantData);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          // fixedSize: ,
                          textStyle: const TextStyle(
                              color: Color.fromARGB(255, 222, 159, 42))),
                      child: const Text(
                        'Participar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Lista expansível para os dias da aposta
  Widget _buildDaysList(List<dynamic> betDays) {
    return ListView.builder(
      itemCount: betDays.length,
      itemBuilder: (context, index) {
        final day = betDays[index];
        return Center(
          child: Container(
            constraints: const BoxConstraints(minWidth: 500, maxWidth: 800),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ExpansionTile(
                  key: ValueKey(day['id']),
                  collapsedBackgroundColor: const Color(0xFF1e1c1b),
                  backgroundColor: const Color(0xFF1e1c1b),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textColor: Colors.white,
                  iconColor: const Color(0xFFcca253),
                  title: Text(
                    "Dia ${day['day']} - ${day['name']}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  children: [
                    _buildDetailRow("Faltas Totais:", "${day['totalFaults']}"),
                    _buildDetailRow("Utilização:", "${day['utilization']}%"),
                    const SizedBox(height: 8),
                    _buildTrainingList(day['trainingReleases']),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Lista de treinos registrados em um dia
  Widget _buildTrainingList(List<dynamic> trainingReleases) {
    if (trainingReleases.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Nenhum treino registrado.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return Column(
      children: trainingReleases.map((training) {
        final comment = training.comment ?? "Sem comentário";
        final trainingType = training.trainingType ?? "Tipo desconhecido";

        return ListTile(
          tileColor: const Color(0xFF282624),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text(
            trainingType,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            comment,
            style: const TextStyle(color: Colors.white70),
          ),
          leading: const Icon(Icons.fitness_center,
              color: Color(0xFFcca253), semanticLabel: "Ícone de treino"),
        );
      }).toList(),
    );
  }

  // Row genérica para exibição de detalhes
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50.0, 4.0, 50.0, 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFcca253),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value!,
            style: TextStyle(color: _getStatusColor(value)),
          ),
        ],
      ),
    );
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'Em Andamento':
        return Colors.green;
      case 'Encerrada':
        return Colors.red;
      case 'Agendada':
        return Colors.orange;
      default:
        return Colors.white;
    }
  }
}
