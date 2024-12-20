import 'dart:convert';
import 'package:daily_training_flutter/services/participants.service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/services/auth.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/users.service.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:daily_training_flutter/screens/training_release.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:daily_training_flutter/providers/participants.privider.dart';

class BetDetailsScreen extends StatefulWidget {
  const BetDetailsScreen({super.key});

  @override
  _BetDetailsScreenState createState() => _BetDetailsScreenState();
}

class _BetDetailsScreenState extends State<BetDetailsScreen>
    with AutomaticKeepAliveClientMixin {
  int? betId;
  User? userData;
  Bet? betDetails;

  bool? isParticipant;
  bool? betClosed;
  bool? betScheduled;
  bool? betInProgress;

  bool _isLoading = true;
  late DateTime currentDate = DateTime.now();

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
      // Dados do usuário logado
      userData = await UsersService.getUserData();

      // Extrai o 'id' da aposta
      betId = await AuthService.getBetDetailsId();
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
    } finally {
      isParticipant = isUserParticipant();
      betClosed = betDetails!.status == 'Encerrada';
      betScheduled = betDetails!.status == 'Agendada';
      betInProgress = betDetails!.status == 'Em Andamento';
    }
  }

  bool isUserParticipant() {
    return betDetails!.participants!.any((participant) =>
        participant['user']['id'] == int.parse('${userData?.id}'));
  }

  bool hasUserTrainedToday() {
    final todayBetDay = betDetails?.betDays?.firstWhere(
      (day) => DateTime.parse(day['day']).day == currentDate.day,
      orElse: () => null,
    );
    if (todayBetDay == null) return false;
    return todayBetDay['trainingReleases'].any((release) =>
        release['participant']['user']['id'] == int.parse('${userData?.id}'));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final participantsProvider = context.watch<ParticipantsProvider>();

    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AllColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: AllColors.gold,
          ),
        ),
      );
    }

    // Identifica o dia atual
    final todayBetDay = betDetails?.betDays?.firstWhere(
      (day) => day['day'] == DateFormat('yyyy-MM-dd').format(currentDate),
      orElse: () => null,
    );

    final participant = betDetails?.participants?.firstWhere(
      (participant) =>
          participant['user']['id'] == int.parse('${userData?.id}'),
      orElse: () => null,
    );

    return Sidebar(
      title: 'Detalhes da Aposta ${betDetails?.id}',
      actions: [
        if (betDetails?.status == 'Agendada')
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-bet',
                arguments: {'betId': betDetails?.id},
              );
            },
            icon: const Icon(
              Icons.edit,
              color: AllColors.orange,
            ),
          ),
      ],
      body: Center(
        child: Container(
          color: AllColors.transparent,
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95),
          child: SingleChildScrollView(
            child: betDetails == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Detalhes da aposta não encontrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: AllColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.025),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/bets',
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AllColors.orange,
                              ),
                              child: const Text(
                                'Ir para Apostas',
                                style: TextStyle(color: AllColors.white),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BetDetailsContainer(
                        userData: userData!,
                        betClosed: betClosed!,
                        betDetails: betDetails!,
                        participant: participant,
                        betScheduled: betScheduled!,
                        betInProgress: betInProgress!,
                        isParticipant: isParticipant!,
                        participantsProvider: participantsProvider,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.015),
                      if (todayBetDay != null)
                        _TodayHighlightContainer(
                          todayBetDay: todayBetDay,
                          participant: participant,
                          betInProgress: betInProgress,
                          userTrained: hasUserTrainedToday(),
                        ),
                      _OtherDaysList(
                        currentDate: currentDate,
                        todayBetDay: todayBetDay,
                        betDays: betDetails!.betDays!,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _BetDetailsContainer extends StatelessWidget {
  User userData;
  Bet betDetails;
  bool betClosed;
  final participant;
  bool betScheduled;
  bool betInProgress;
  bool isParticipant;
  ParticipantsProvider participantsProvider;

  _BetDetailsContainer({
    this.participant,
    required this.userData,
    required this.betClosed,
    required this.betDetails,
    required this.betScheduled,
    required this.betInProgress,
    required this.isParticipant,
    required this.participantsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AllColors.transparent,
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Card(
        color: AllColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 500, maxWidth: 700),
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              decoration: BoxDecoration(
                color: AllColors.card,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 15,
                    color: AllColors.statusBet[betDetails.status] ??
                        AllColors.transparent,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/bets',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          backgroundColor: AllColors.transparent,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Icon(
                          size: 22,
                          Icons.arrow_back,
                          color: AllColors.white,
                        ),
                      ),
                      Text(
                        '${betDetails.status}',
                        style: TextStyle(
                          fontSize: 18,
                          color: AllColors.statusBet[betDetails.status],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${betDetails.duration} dia(s)',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AllColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Início: ${DateFormat('dd/MM/yyyy').format(betDetails.initialDate!)}',
                        style: const TextStyle(
                            fontSize: 12, color: AllColors.text),
                      ),
                      Text(
                        'Término: ${DateFormat('dd/MM/yyyy').format(betDetails.finalDate!)}',
                        style: const TextStyle(
                            fontSize: 12, color: AllColors.text),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Faltas Permitidas: ',
                            style:
                                TextStyle(fontSize: 12, color: AllColors.text),
                          ),
                          Text(
                            '${betDetails.faultsAllowed!}',
                            style: const TextStyle(
                                fontSize: 12, color: AllColors.text),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Penalidade: ',
                            style:
                                TextStyle(fontSize: 12, color: AllColors.text),
                          ),
                          Text(
                            NumberFormat.currency(
                                    locale: 'pt_BR', symbol: 'R\$')
                                .format(betDetails.minimumPenaltyAmount),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  betClosed ? AllColors.white : AllColors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _ParticipantsModal(
                            betStatus: betDetails.status!,
                            participants: betDetails.participants,
                          ).show(context);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AllColors.transparent,
                          side: BorderSide(
                            color: AllColors.statusBet[betDetails.status] ??
                                AllColors.white,
                          ),
                        ),
                        child: Text(
                          'Ver Participantes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AllColors.statusBet[betDetails.status],
                          ),
                        ),
                      ),
                      if (betScheduled)
                        if (!isParticipant)
                          ElevatedButton(
                            onPressed: () async {
                              final participantData = {
                                'userId': userData.id,
                                'trainingBetId': betDetails.id,
                              };
                              await participantsProvider
                                  .create(participantData);

                              Navigator.pushNamed(context, '/bet-details');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AllColors.orange,
                            ),
                            child: const Text(
                              'Participar',
                              style: TextStyle(
                                color: AllColors.white,
                              ),
                            ),
                          ),
                      if (betClosed)
                        OutlinedButton(
                          onPressed: () => _WinnersModal(
                                  betStatus: betDetails.status!,
                                  participants: betDetails.participants)
                              .show(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AllColors.gold,
                            ),
                            backgroundColor: AllColors.transparent,
                          ),
                          child: const Text(
                            'Ver Ganhadores!',
                            style: TextStyle(
                              color: AllColors.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (participant != null &&
                      participant['declassified'] == true)
                    const Center(
                      child: Text(
                        'Desclassificado por limite de faltas',
                        style: TextStyle(
                          fontSize: 12,
                          color: AllColors.red,
                        ),
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

class _TodayHighlightContainer extends StatelessWidget {
  bool userTrained;
  final participant;
  final betInProgress;
  Map<String, dynamic> todayBetDay;

  _TodayHighlightContainer({
    this.participant,
    required this.todayBetDay,
    required this.userTrained,
    required this.betInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final participantId =
        participant == null ? participant : participant!['id'];

    final trainingReleasesIsEmpty =
        (todayBetDay['trainingReleases'] as List<dynamic>).isEmpty;

    return Center(
      child: Container(
        color: AllColors.transparent,
        constraints: BoxConstraints(
          maxWidth: (MediaQuery.of(context).size.width > 500)
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.9,
        ),
        child: Card(
          elevation: 0,
          color: AllColors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoje: ${todayBetDay['name']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AllColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(todayBetDay['day'])),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AllColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Treinos Totais',
                        style: TextStyle(fontSize: 12, color: AllColors.text),
                      ),
                      Text(
                        '${todayBetDay['trainingReleases'].length}',
                        style: const TextStyle(
                            fontSize: 14, color: AllColors.text),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Aproveitamento',
                        style: TextStyle(fontSize: 12, color: AllColors.text),
                      ),
                      Text(
                        '${todayBetDay['utilization']}%',
                        style: const TextStyle(
                            fontSize: 14, color: AllColors.text),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Somente exibe o botão se o usuário for um participante e não tiver registrado treino ainda
                  if (betInProgress! && !userTrained && participantId != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LaunchTrainingScreen(
                              betDayId: todayBetDay['id'],
                              participantId: participantId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AllColors.gold),
                      child: const Text(
                        'Lançar Treino',
                        style: TextStyle(
                          fontSize: 14,
                          color: AllColors.text,
                        ),
                      ),
                    ),
                  if (!trainingReleasesIsEmpty)
                    OutlinedButton(
                      onPressed: () => _TrainingModal(
                        trainingReleases: todayBetDay['trainingReleases'],
                      ).show(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AllColors.gold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ver Treinos',
                        style: TextStyle(fontSize: 14, color: AllColors.gold),
                      ),
                    ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              const Row(
                children: [
                  Text(
                    'Dias de Treino',
                    style: TextStyle(
                      fontSize: 18,
                      color: AllColors.white,
                      fontWeight: FontWeight.bold,
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
}

class _OtherDaysList extends StatelessWidget {
  final currentDate;
  List<dynamic> betDays;
  Map<String, dynamic>? todayBetDay;

  _OtherDaysList({
    this.todayBetDay,
    required this.betDays,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final todayIndex = todayBetDay != null ? betDays.indexOf(todayBetDay) : -1;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: (MediaQuery.of(context).size.width > 500)
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.85,
        ),
        child: ListView.builder(
          itemCount: betDays.length,
          itemBuilder: (context, index) {
            if (index == todayIndex) return const SizedBox.shrink();

            final day = betDays[index];
            final dayDate = DateTime.parse(day['day']);
            final isFuture = dayDate.isAfter(currentDate);
            final trainingReleasesIsEmpty =
                (day['trainingReleases'] as List<dynamic>).isEmpty;

            return Card(
              color: AllColors.card,
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: AllColors.white,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(day['day'])),
                      style:
                          const TextStyle(fontSize: 16, color: AllColors.gold),
                    )
                  ],
                ),
                subtitle: isFuture
                    ? const Text(
                        'Status: Em breve',
                        style: TextStyle(color: AllColors.softWhite),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.015,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Faltas: ${day['totalFaults']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AllColors.softWhite,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Treinos: ${day['trainingReleases'].length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AllColors.softWhite,
                                    ),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'Status: Concluído',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AllColors.softWhite,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Aproveitamento: ${day['utilization']}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AllColors.softWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                iconSize: 18,
                                icon: Icon(
                                  !trainingReleasesIsEmpty
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AllColors.white,
                                ),
                                onPressed: trainingReleasesIsEmpty
                                    ? null
                                    : () => _TrainingModal(
                                          trainingReleases:
                                              day['trainingReleases'],
                                        ).show(context),
                              ),
                              Text(
                                !trainingReleasesIsEmpty
                                    ? 'Ver Treinos'
                                    : 'Sem Treinos',
                                style: const TextStyle(
                                    color: AllColors.text, fontSize: 12),
                              )
                            ],
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParticipantsModal {
  String betStatus;
  List<dynamic>? participants;

  _ParticipantsModal({required this.betStatus, this.participants});

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AllColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return participants == null || participants!.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Nenhum participante no momento',
                    style: TextStyle(fontSize: 16, color: AllColors.text),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: participants?.length,
                itemBuilder: (BuildContext context, int index) {
                  final participant = participants?[index];

                  final imagePath = participant['user']['profileImagePath'];
                  final decodedImage =
                      imagePath != null ? base64Decode(imagePath) : null;

                  var subtitleText =
                      'Faltas: ${participant['faults']} / Aproveitamento: ${participant['utilization']}%';
                  if (betStatus == 'Agendada') {
                    subtitleText =
                        'Vitórias: ${participant['user']['wins']} / Derrotas: ${participant['user']['losses']}';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: decodedImage != null
                          ? AllColors.transparent
                          : AllColors.statusBet[betStatus],
                      child: decodedImage != null
                          ? ClipOval(
                              child: Image.memory(
                                decodedImage,
                                errorBuilder: (context, error, stackTrace) =>
                                    Column(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: AllColors.red,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                    )
                                  ],
                                ),
                              ),
                            )
                          : Text(
                              participant['user']['name']
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(color: AllColors.white),
                            ),
                    ),
                    title: Text(
                      participant['user']['name'],
                      style:
                          const TextStyle(fontSize: 16, color: AllColors.text),
                    ),
                    subtitle: Text(
                      subtitleText,
                      style:
                          const TextStyle(fontSize: 12, color: AllColors.text),
                    ),
                  );
                },
              );
      },
    );
  }
}

class _WinnersModal {
  String betStatus;
  List<dynamic>? participants;

  _WinnersModal({required this.betStatus, this.participants});

  void show(BuildContext context) {
    final winners =
        participants?.where((p) => p['declassified'] == false).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AllColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return participants == null || participants!.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Nenhum participante no momento',
                    style: TextStyle(fontSize: 16, color: AllColors.text),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: winners?.length,
                itemBuilder: (BuildContext context, int index) {
                  final participant = winners?[index];

                  final imagePath = participant['user']['profileImagePath'];
                  final decodedImage =
                      imagePath != null ? base64Decode(imagePath) : null;

                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: AllColors.orange),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: decodedImage != null
                              ? AllColors.transparent
                              // : AllColors.statusBet[betStatus],
                              : AllColors.softGold,
                          child: decodedImage != null
                              ? ClipOval(
                                  child: Image.memory(
                                    decodedImage,
                                    errorBuilder:
                                        (context, error, stackTrace) => Column(
                                      children: [
                                        const Icon(
                                          Icons.error,
                                          color: AllColors.red,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Text(
                                  participant['user']['name']
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(color: AllColors.white),
                                ),
                        ),
                      ],
                    ),
                    title: Text(
                      participant['user']['name'],
                      style:
                          const TextStyle(fontSize: 16, color: AllColors.text),
                    ),
                    subtitle: Text(
                      'Aproveitamento: ${participant['utilization']} / Faltas: ${participant['faults']}',
                      style:
                          const TextStyle(fontSize: 12, color: AllColors.text),
                    ),
                  );
                },
              );
      },
    );
  }
}

class _TrainingModal {
  List trainingReleases;

  _TrainingModal({required this.trainingReleases});

  void show(BuildContext context) {
    PageController pageController = PageController();

    showModalBottomSheet(
      elevation: 0,
      context: context,
      isScrollControlled: true,
      backgroundColor: AllColors.background,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AllColors.softWhite, width: 2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double currentPage = 0.0;

            // Adiciona listener para atualizar o estado conforme o carrossel é rolado
            pageController.addListener(() {
              setState(() {
                currentPage = pageController.page ?? 0.0;
              });
            });

            return Center(
              child: Container(
                color: AllColors.transparent,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: Column(
                  children: [
                    // Cabeçalho
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.05,
                        0,
                        MediaQuery.of(context).size.width * 0.05,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const IconButton(
                            onPressed: null,
                            icon:
                                Icon(Icons.close, color: AllColors.transparent),
                          ),
                          const Text(
                            'Treinos Realizados',
                            style: TextStyle(
                              fontSize: 16,
                              color: AllColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon:
                                const Icon(Icons.close, color: AllColors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Expanded(
                      child: custom_carousel.CarouselSlider.builder(
                        itemCount: trainingReleases.length,
                        itemBuilder: (context, index, realIndex) {
                          final training = trainingReleases[index];
                          final participant = training['participant'];

                          final user = participant['user'];
                          final imagePath = training['imagePath'];
                          final decodedImage = imagePath != null
                              ? base64Decode(imagePath)
                              : null;

                          final scale =
                              (1 - (currentPage - index).abs()).clamp(1.0, 1.2);

                          return Transform.scale(
                            scale: scale,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                decodedImage != null
                                    ? Image.memory(
                                        decodedImage,
                                        width:
                                            (MediaQuery.of(context).size.width *
                                                    0.8) *
                                                scale,
                                        height: (MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.5) *
                                            scale,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Column(
                                          children: [
                                            const Icon(
                                              Icons.error,
                                              color: AllColors.red,
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                            )
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25),
                                          const Icon(
                                            Icons.error,
                                            color: AllColors.red,
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25),
                                        ],
                                      ),
                                Text(
                                  '${training['trainingType']} - ${user['name']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AllColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  'Faltas: ${participant['faults']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AllColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Text(
                                  'Aproveitamento: ${participant['utilization']}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AllColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Desclassificado:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AllColors.text),
                                    ),
                                    Icon(
                                      participant['declassified']
                                          ? Icons.check
                                          : Icons.close,
                                      color: participant['declassified']
                                          ? Colors.green
                                          : Colors.red,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        options: custom_carousel.CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          height: MediaQuery.of(context).size.height * 0.8,
                          autoPlayInterval: const Duration(seconds: 3),
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentPage = index.toDouble();
                            });
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        trainingReleases.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: currentPage == index ? 12.0 : 8.0,
                          height: currentPage == index ? 12.0 : 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? AllColors.white
                                : AllColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
