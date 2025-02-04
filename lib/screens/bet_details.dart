import 'dart:convert';
import 'package:daily_training_flutter/services/participants.service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/services/auth.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/users.service.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:daily_training_flutter/services/bet_day.service.dart';
import 'package:daily_training_flutter/screens/training_release.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:carousel_slider/carousel_slider.dart' as custom_carousel;
import 'package:daily_training_flutter/widgets/CustomElevatedButton.dart';
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
      // Dados do usuário logado
      userData = await UsersService.getUserData();

      // Extrai o 'id' da aposta
      betId = await AuthService.getBetDetailsId();
      if (betId == null) throw Exception('Aposta não informada');

      // Pegando os detalhes da aposta
      final betsProvider = Provider.of<BetsProvider>(context, listen: false);

      await betsProvider.getBetDetails(betId);
      betDetails = betsProvider.bets.isEmpty
          ? throw Exception('Aposta não encontrada')
          : betsProvider.bets[0];

      // Update loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    return betDetails!.participants!
        .any((participant) => participant.user?.id == userData?.id);
  }

  bool hasUserTrainedToday() {
    final todayBetDay = betDetails?.betDays?.firstWhereOrNull(
      (day) => DateTime.parse(day.day!).day == currentDate.day,
    );
    if (todayBetDay == null) return false;
    return todayBetDay.trainingReleases!.any((release) =>
        release.participant!.user!.id == int.parse('${userData?.id}'));
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
    BetDay? todayBetDay = betDetails?.betDays?.firstWhereOrNull(
      (day) => day.day == DateFormat('yyyy-MM-dd').format(currentDate),
    );

    Participants? participant = betDetails?.participants?.firstWhereOrNull(
      (participant) => participant.user?.id == userData?.id,
    );

    return Sidebar(
      title: 'Detalhes da Aposta ${betDetails?.id ?? ""}',
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
                            Text(
                              'Detalhes da aposta $betId não encontrados',
                              style: const TextStyle(
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
                                backgroundColor: AllColors.gold,
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
                          betId: betDetails!.id!,
                          todayBetDay: todayBetDay,
                          participant: participant,
                          betInProgress: betInProgress,
                          userTrained: hasUserTrainedToday(),
                        ),
                      _OtherDaysList(
                        betId: betDetails!.id!,
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
  bool betScheduled;
  bool betInProgress;
  bool isParticipant;
  Participants? participant;
  ParticipantsProvider participantsProvider;
  final ValueNotifier<bool> isCreatingParticipant = ValueNotifier<bool>(false);

  _BetDetailsContainer({
    required this.userData,
    required this.betClosed,
    required this.betDetails,
    required this.participant,
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
                      CustomElevatedButton(
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        backgroundColor: AllColors.transparent,
                        maximumSize: const Size(35, 35),
                        minimumSize: const Size(35, 35),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/bets',
                          );
                        },
                        child: const Icon(
                          size: 22,
                          Icons.arrow_back,
                          color: AllColors.white,
                        ),
                      ),
                      Text(
                        '${betDetails.status}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AllColors.statusBet[betDetails.status],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${betDetails.duration} dia(s)',
                            style: const TextStyle(
                              fontSize: 16,
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
                  Wrap(
                    spacing: 8.0, // Espaço horizontal entre os botões
                    runSpacing: 8.0, // Espaço vertical entre as linhas
                    alignment: WrapAlignment.center, // Alinhamento horizontal
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _ParticipantsModal(
                            userId: userData.id!,
                            betId: betDetails.id!,
                            betStatus: betDetails.status!,
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
                          ValueListenableBuilder<bool>(
                            valueListenable: isCreatingParticipant,
                            builder: (context, isLoading, child) {
                              return CustomElevatedButton(
                                borderRadius: 15,
                                isLoading: isLoading,
                                backgroundColor: AllColors.orange,
                                onPressed: () async {
                                  try {
                                    isCreatingParticipant.value = true;
                                    final participantData = {
                                      'userId': userData.id,
                                      'trainingBetId': betDetails.id,
                                    };
                                    await participantsProvider
                                        .create(participantData);

                                    if (participantsProvider.errorMessage !=
                                        null) {
                                      throw Exception(
                                          participantsProvider.errorMessage);
                                    } else {
                                      Navigator.pushNamed(
                                          context, '/bet-details');
                                    }
                                  } catch (e) {
                                    final errorMessage = e
                                        .toString()
                                        .replaceFirst('Exception: ', '');
                                    const signinMessage =
                                        'Token expirado. Faça o login novamente';

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                        errorMessage,
                                        style: const TextStyle(
                                            color: AllColors.red),
                                      )),
                                    );
                                    if (errorMessage == signinMessage) {
                                      Navigator.pushNamed(context, '/');
                                    }
                                  } finally {
                                    isCreatingParticipant.value = false;
                                  }
                                },
                                child: const Text(
                                  'Participar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AllColors.white,
                                  ),
                                ),
                              );
                            },
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
                              fontSize: 12,
                              color: AllColors.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  if (participant != null && participant!.declassified == true)
                    const Center(
                      child: Text(
                        'Desclassificado por limite de faltas',
                        style: TextStyle(
                          fontSize: 12,
                          color: AllColors.red,
                          fontStyle: FontStyle.italic,
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
  int betId;
  bool userTrained;
  final betInProgress;
  BetDay todayBetDay;
  Participants? participant;

  _TodayHighlightContainer({
    this.participant,
    required this.betId,
    required this.todayBetDay,
    required this.userTrained,
    required this.betInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final participantId = participant?.id;
    final trainingReleasesIsEmpty = todayBetDay.trainingReleases?.isEmpty;

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
                    'Hoje: ${todayBetDay.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AllColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(todayBetDay.day!)),
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Treinos Totais',
                        style: TextStyle(fontSize: 12, color: AllColors.text),
                      ),
                      Text(
                        '${todayBetDay.trainingReleases?.length}',
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
                        '${todayBetDay.utilization}%',
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
                    CustomElevatedButton(
                      fontSize: 12,
                      labelText: 'Lançar Treino',
                      backgroundColor: AllColors.gold,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LaunchTrainingScreen(
                              betDayId: todayBetDay.id!,
                              participantId: participantId,
                            ),
                          ),
                        );
                      },
                    ),
                  if (!trainingReleasesIsEmpty!)
                    OutlinedButton(
                      onPressed: () => _TrainingModal(
                        betId: betId,
                        betDay: todayBetDay,
                        trainingReleases: todayBetDay.trainingReleases!,
                      ).show(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AllColors.gold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ver Treinos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AllColors.gold,
                        ),
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
                      fontSize: 16,
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
  int betId;
  final currentDate;
  BetDay? todayBetDay;
  List<BetDay?> betDays;

  _OtherDaysList({
    this.todayBetDay,
    required this.betId,
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
          maxWidth: (MediaQuery.of(context).size.width > 900)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width * 0.85,
        ),
        child: ListView.builder(
          itemCount: betDays.length,
          itemBuilder: (context, index) {
            if (index == todayIndex) return const SizedBox.shrink();

            final day = betDays[index];
            final dayDate = DateTime.parse(day!.day!);
            final isFuture = dayDate.isAfter(currentDate);
            final trainingReleasesIsEmpty =
                (day.trainingReleases as List<dynamic>).isEmpty;

            return Card(
              color: AllColors.card,
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day.name!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AllColors.white,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.parse(day.day!)),
                      style:
                          const TextStyle(fontSize: 14, color: AllColors.gold),
                    )
                  ],
                ),
                subtitle: isFuture
                    ? const Text(
                        'Status: Em breve',
                        style: TextStyle(
                          fontSize: 12,
                          color: AllColors.softWhite,
                        ),
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
                                    'Faltas: ${day.totalFaults}',
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
                                    'Treinos: ${day.trainingReleases?.length}',
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
                                    'Aproveitamento: ${day.utilization}%',
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
                                          betDay: day,
                                          betId: betId,
                                          trainingReleases:
                                              day.trainingReleases!,
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
  int betId;
  int userId;
  String betStatus;
  bool? userIsWinner;
  List<Participants>? winners;
  List<Participants>? participants;
  final participantsProvider = ParticipantsProvider();

  _ParticipantsModal({
    required this.betId,
    required this.userId,
    required this.betStatus,
  });

  bool verifyIfUserIsWinner(List<dynamic> winners) {
    return winners.any((participant) =>
        participant.user != null && participant.user.id == userId);
  }

  void show(BuildContext context) async {
    winners = await participantsProvider.winningParticipants(betId);
    participants = await participantsProvider.participantsByTrainingBet(betId);
    userIsWinner = verifyIfUserIsWinner(winners!);

    showModalBottomSheet(
      context: context,
      backgroundColor: AllColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            Future<void> refreshParticipants() async {
              participants =
                  await participantsProvider.participantsByTrainingBet(betId);
              setModalState(() {});
            }

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

                      final imagePath = participant?.user?.profileImagePath;
                      final decodedImage =
                          imagePath != null ? base64Decode(imagePath) : null;

                      var subtitleText =
                          'Faltas: ${participant?.faults} / Aproveitamento: ${participant?.utilization}%';
                      if (betStatus == 'Agendada') {
                        subtitleText =
                            'Vitórias: ${participant?.user?.wins} / Derrotas: ${participant?.user?.losses}';
                      }

                      const sizeProfileImage = 100.0;
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: ListTile(
                                  leading: CircleAvatar(
                                      radius: sizeProfileImage * 0.26,
                                      backgroundColor:
                                          participant?.user?.id == userId
                                              ? AllColors.gold
                                              : AllColors.transparent,
                                      child: CircleAvatar(
                                        radius: sizeProfileImage * 0.24,
                                        backgroundColor: decodedImage != null
                                            ? AllColors.background
                                            : AllColors.statusBet[betStatus],
                                        child: decodedImage != null
                                            ? ClipOval(
                                                child: Image.memory(
                                                  width: 100,
                                                  height: 100,
                                                  decodedImage,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) =>
                                                      const Icon(
                                                    Icons.error,
                                                    color: AllColors.red,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                participant!.user!.name!
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: AllColors.white,
                                                ),
                                              ),
                                      )),
                                  title: Text(
                                    participant!.user!.name!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AllColors.text,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (participant.declassified == true)
                                        Row(
                                          children: [
                                            const Text(
                                              'Desclassificado',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AllColors.red,
                                              ),
                                            ),
                                            if (betStatus == 'Encerrada' &&
                                                participant.penaltyPaid ==
                                                    false)
                                              Text(
                                                ': ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(participant.penaltyAmount)}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AllColors.red,
                                                ),
                                              ),
                                          ],
                                        ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.005,
                                      ),
                                      Text(
                                        subtitleText,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AllColors.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (userIsWinner == true &&
                                  betStatus == 'Encerrada' &&
                                  participant.declassified == true &&
                                  participant.penaltyPaid == false)
                                ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await participantsProvider
                                            .updatePenaltyPaid(
                                                participant.id!, betId);
                                        await refreshParticipants(); // Recarrega os dados
                                      } catch (e) {
                                        Navigator.pop(context);
                                        final message = e
                                            .toString()
                                            .replaceAll('Exception: ', '');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                            message,
                                            style: const TextStyle(
                                              color: AllColors.red,
                                            ),
                                          )),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 1,
                                      padding: const EdgeInsets.all(5),
                                      backgroundColor: AllColors.softBackground,
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          '\$ ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AllColors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Confirmar',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AllColors.softWhite,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ))
                              else if (participant.declassified == true &&
                                  participant.penaltyPaid == true)
                                const Icon(
                                  Icons.check,
                                  color: AllColors.green,
                                )
                            ],
                          ),
                        ],
                      );
                    },
                  );
          },
        );
      },
    );
  }
}

class _WinnersModal {
  String betStatus;
  List<Participants>? participants;

  _WinnersModal({required this.betStatus, this.participants});

  void show(BuildContext context) {
    final winners =
        participants?.where((p) => p.declassified == false).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AllColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return winners == null || winners.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Não houve ganhadores',
                    style: TextStyle(fontSize: 16, color: AllColors.text),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: winners.length,
                itemBuilder: (BuildContext context, int index) {
                  final participant = winners[index];

                  final imagePath = participant.user?.profileImagePath;
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
                                    width: 100,
                                    height: 100,
                                    decodedImage,
                                    fit: BoxFit.cover,
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
                                  participant.user!.name!
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(color: AllColors.white),
                                ),
                        ),
                      ],
                    ),
                    title: Text(
                      participant.user!.name!,
                      style:
                          const TextStyle(fontSize: 16, color: AllColors.text),
                    ),
                    subtitle: Text(
                      'Aproveitamento: ${participant.utilization} / Faltas: ${participant.faults}',
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
  int betId;
  BetDay betDay;
  List trainingReleases;

  _TrainingModal(
      {required this.trainingReleases,
      required this.betId,
      required this.betDay});

  final mapTrainingIcons = {
    'Natação': const Icon(Icons.pool, color: Colors.teal),
    'Outros': const Icon(Icons.more_horiz, color: Colors.grey),
    'Luta': const Icon(Icons.sports_kabaddi, color: Colors.red),
    'Corrida': const Icon(Icons.directions_run, color: Colors.green),
    'Musculação': const Icon(Icons.fitness_center, color: Colors.blue),
    'Vôlei': const Icon(Icons.sports_volleyball, color: Colors.orange),
    'Ciclismo': const Icon(Icons.directions_bike, color: Colors.purple),
  };

  void show(BuildContext context) {
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
        // ValueNotifier para rastrear a página atual
        final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

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
                        icon: Icon(Icons.close, color: AllColors.transparent),
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
                        icon: const Icon(
                          size: 25,
                          Icons.close,
                          color: AllColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: custom_carousel.CarouselSlider.builder(
                    itemCount: trainingReleases.length,
                    itemBuilder: (context, index, realIndex) {
                      final training = trainingReleases[index];
                      final participant = training.participant;

                      final user = participant.user;
                      final decodedUserImage = user.profileImagePath != null
                          ? base64Decode(user.profileImagePath)
                          : null;

                      final imagePath = training.imagePath;
                      final decodedTrainingImage =
                          imagePath != null ? base64Decode(imagePath) : null;

                      final scale =
                          (1 - (currentPageNotifier.value - index).abs())
                              .clamp(1.0, 1.2);

                      return Transform.scale(
                        scale: scale.toDouble(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            decodedTrainingImage != null
                                ? Image.memory(
                                    decodedTrainingImage,
                                    width: (MediaQuery.of(context).size.width *
                                            0.8) *
                                        scale,
                                    height:
                                        (MediaQuery.of(context).size.height *
                                                0.5) *
                                            scale,
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
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15),
                                      const Icon(
                                        Icons.error,
                                        color: AllColors.red,
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.15),
                                    ],
                                  ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                mapTrainingIcons[training.trainingType]!,
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.015,
                                ),
                                Text(
                                  '${training.trainingType}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AllColors.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.width * 0.025,
                                  backgroundColor: const Color(0xFF282624),
                                  child: decodedUserImage == null
                                      ? Icon(
                                          Icons.person,
                                          color: AllColors.gold,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035,
                                        )
                                      : ClipOval(
                                          child: Image.memory(
                                            width: 100,
                                            height: 100,
                                            decodedUserImage,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Column(
                                              children: [
                                                Icon(
                                                  Icons.person,
                                                  color: AllColors.gold,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.035,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                Text(
                                  '${user.name} na Aposta $betId:',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    decorationThickness: 1,
                                    color: AllColors.gold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (training.comment != null ||
                                    training.comment != '')
                                  Text(
                                    'Comentário: ${training.comment}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      decorationThickness: 1,
                                      color: AllColors.text,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        'Faltas:',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AllColors.text,
                                        ),
                                      ),
                                      Text(
                                        '${participant.faults}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AllColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        'Aproveitamento:',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AllColors.text,
                                        ),
                                      ),
                                      Text(
                                        '${participant.utilization}%',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AllColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            if (participant.declassified)
                              const Text(
                                'Desclassificado por faltas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AllColors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                          ],
                        ),
                      );
                    },
                    options: custom_carousel.CarouselOptions(
                      aspectRatio: 16 / 9,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      height: MediaQuery.of(context).size.height * 0.8,
                      onPageChanged: (index, reason) {
                        currentPageNotifier.value = index;
                      },
                    ),
                  ),
                ),
                // Indicadores
                ValueListenableBuilder<int>(
                  valueListenable: currentPageNotifier,
                  builder: (context, currentPage, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        trainingReleases.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: currentPage == index ? 14.0 : 8.0,
                          height: currentPage == index ? 14.0 : 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? AllColors.gold
                                : AllColors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
