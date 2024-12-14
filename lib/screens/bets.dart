import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/utils/AllColors.dart';
import 'package:daily_training_flutter/widgets/Sidebar.dart';
import 'package:daily_training_flutter/services/auth.service.dart';
import 'package:daily_training_flutter/services/bets.service.dart';
import 'package:daily_training_flutter/services/users.service.dart';
import 'package:daily_training_flutter/providers/bets.provider.dart';
import 'package:daily_training_flutter/providers/participants.privider.dart';

class BetsScreen extends StatefulWidget {
  const BetsScreen({Key? key}) : super(key: key);

  @override
  _BetsScreenState createState() => _BetsScreenState();
}

class _BetsScreenState extends State<BetsScreen>
    with AutomaticKeepAliveClientMixin {
  User? userData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;

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
      // Fetch user data
      userData = await _safeGetUserData();

      // Fetch bets
      await _safeFetchBets();

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
          SnackBar(content: Text('Falha ao buscar dados: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<User?> _safeGetUserData() async {
    try {
      return await AuthService.getUserData();
    } catch (e) {
      return null;
    }
  }

  Future<void> _safeFetchBets() async {
    try {
      // Ensure we're using the context from the current build phase
      await Future.microtask(() {
        Provider.of<ParticipantsProvider>(context, listen: false);
        Provider.of<BetsProvider>(context, listen: false).fetchBets();
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final betsProvider = context.watch<BetsProvider>();
    final participantsProvider = context.watch<ParticipantsProvider>();

    if (_isLoading) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AllColors.background,
        body: const Center(
          child: CircularProgressIndicator(
            color: AllColors.orange,
          ),
        ),
      );
    }

    // Check for null or empty user data
    if (userData == null) {
      AuthService.signup(context);
    }

    if (betsProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AllColors.orange,
        ),
      );
    }

    return Sidebar(
      title: 'Apostas',
      body: _buildBody(betsProvider, participantsProvider),
    );
  }

  Widget _buildBody(BetsProvider betsProvider, participantsProvider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 500, maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (betsProvider.highlightedBet != null)
                _HighlightedBet(
                    userId: userData?.id,
                    bet: betsProvider.highlightedBet!,
                    participantsProvider: participantsProvider),
              const SizedBox(height: 60),
              if (betsProvider.bets.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Outras Apostas',
                        style: TextStyle(
                          color: AllColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                          child: ListView.builder(
                        itemCount: betsProvider.bets.length,
                        itemBuilder: (context, index) {
                          final bet = betsProvider.bets[index];
                          return _betCard(context, bet);
                        },
                      )),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _betCard(BuildContext context, bet) {
    return Card(
        color: AllColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: InkWell(
          hoverColor: AllColors.hoverCard,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Ícone à esquerda
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AllColors.softBlack,
                  ),
                  child: Icon(
                    Icons.sports_esports,
                    size: 28,
                    color: AllColors.statusBet[bet.status],
                  ),
                ),
                const SizedBox(width: 16),
                // Informações principais
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aposta ${bet.id}',
                        style: const TextStyle(
                          color: AllColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duração: ${bet.duration} dias',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AllColors.softWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status da aposta
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AllColors.statusBet[bet.status],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bet.status.toUpperCase(),
                          style: const TextStyle(
                            color: AllColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão para detalhes
                IconButton(
                  onPressed: () async {
                    await AuthService.setBetDetailsId(bet.id);
                    Navigator.pushNamed(context, '/bet-details');
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: AllColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _HighlightedBet extends StatelessWidget {
  final userId;
  final Bet bet;
  final ParticipantsProvider participantsProvider;

  const _HighlightedBet(
      {required this.bet,
      required this.userId,
      required this.participantsProvider});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            constraints: const BoxConstraints(minWidth: 500, maxWidth: 700),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AllColors.card,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: AllColors.grey, blurRadius: 15),
              ],
            ),
            child: bet.status == 'Em Andamento'
                ? inProgressBet(context)
                : bet.status == 'Agendada'
                    ? scheduleBet(context)
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Nenhuma aposta em destaque no momento',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: AllColors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 35,
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/new-bet'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AllColors.orange),
                              child: const Text(
                                'Agende um aposta',
                                style: TextStyle(color: AllColors.white),
                              ),
                            ),
                          ],
                        ),
                      )));
  }

  Widget inProgressBet(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: Text(
          'Aposta ${bet.status}',
          style: TextStyle(
            fontSize: 18,
            color: AllColors.statusBet[bet.status],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 8),
              Text(
                'Duração: ${bet.duration} dias',
                style: const TextStyle(color: AllColors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Início: ${DateFormat('dd/MM/yyyy').format(bet.initialDate ?? DateTime.now())}',
                style: const TextStyle(color: AllColors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Fim: ${DateFormat('dd/MM/yyyy').format(bet.finalDate ?? DateTime.now())}',
                style: const TextStyle(color: AllColors.white, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await AuthService.setBetDetailsId(bet.id);
                  Navigator.pushNamed(context, '/bet-details');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AllColors.statusBet[bet.status],
                    textStyle: const TextStyle(color: AllColors.background)),
                child: const Text(
                  'Ver Detalhes',
                  style: TextStyle(color: AllColors.white),
                ),
              ),
            ],
          )
        ],
      ),
    ]);
  }

  Widget scheduleBet(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
          child: Row(
        children: [
          const Text(
            'Próxima Aposta ',
            style: TextStyle(
              fontSize: 18,
              color: AllColors.white,
            ),
          ),
          Text(
            '${bet.status}',
            style: TextStyle(
              fontSize: 18,
              color: AllColors.statusBet[bet.status],
            ),
          ),
        ],
      )),
      const SizedBox(height: 20),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(height: 8),
              Text(
                'Duração: ${bet.duration} dias',
                style: const TextStyle(color: AllColors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Início: ${DateFormat('dd/MM/yyyy').format(bet.initialDate ?? DateTime.now())}',
                style: const TextStyle(color: AllColors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Fim: ${DateFormat('dd/MM/yyyy').format(bet.finalDate ?? DateTime.now())}',
                style: const TextStyle(color: AllColors.white, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton(
                onPressed: () async {
                  await AuthService.setBetDetailsId(bet.id);
                  Navigator.pushNamed(context, '/bet-details');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AllColors.gold),
                ),
                child: Text(
                  'Detalhes',
                  style: TextStyle(
                    color: AllColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.033,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ]);
  }
}
