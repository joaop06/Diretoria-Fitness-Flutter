import 'package:daily_training_flutter/providers/participants.privider.dart';
import 'package:daily_training_flutter/services/participants_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/screens/bet_details.dart';
import 'package:daily_training_flutter/services/auth_service.dart';
import 'package:daily_training_flutter/services/bets_service.dart';
import 'package:daily_training_flutter/services/users_service.dart';
import 'package:daily_training_flutter/providers/bets_provider.dart';

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
    // Use WidgetsBinding to ensure the widget is fully initialized
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
        backgroundColor: const Color(0xFF1e1c1b),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFCCA253),
          ),
        ),
      );
    }

    // Check for null or empty user data
    if (userData == null) {
      AuthService.signup(context);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1e1c1b),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 12, 12),
        elevation: 4,
        title: const Text(
          "Apostas",
          style: TextStyle(color: Colors.white),
        ),
        leading: _buildLeadingAvatar(),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(betsProvider, participantsProvider),
    );
  }

  Widget _buildLeadingAvatar() {
    String? userName = userData?.name;
    String? userImageUrl = userData?.profileImagePath;

    return GestureDetector(
      onTap: () => _scaffoldKey.currentState?.openDrawer(),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
          image: userImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(userImageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: userImageUrl == null
            ? Center(
                child: Text(
                  userName![0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildDrawer() {
    String? userName = userData?.name;
    String? userImageUrl = userData?.profileImagePath;

    return Drawer(
      backgroundColor: const Color(0xFF282624),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1e1c1b),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      userImageUrl != null ? NetworkImage(userImageUrl) : null,
                  child: userImageUrl == null
                      ? Text(
                          userName![0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  userName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white),
            title: const Text("Editar Dados",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/edit-user');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.white),
            title: const Text("Nova Aposta",
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/new-bet');
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard, color: Colors.white),
            title: const Text("Ranking", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/ranking');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text("Sair", style: TextStyle(color: Colors.white)),
            onTap: () async {
              // SignUp
              await AuthService.signup(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BetsProvider betsProvider, participantsProvider) {
    if (betsProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFCCA253),
        ),
      );
    }

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
              const Text(
                'Outras Apostas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: betsProvider.bets.isNotEmpty
                    ? ListView.builder(
                        itemCount: betsProvider.bets.length,
                        itemBuilder: (context, index) {
                          final bet = betsProvider.bets[index];
                          return betCard(context, bet);
                        },
                      )
                    : const Center(
                        child: Text(
                          'Não há mais apostas',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loading(BuildContext context) {
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

  Widget otherBets(BuildContext context, betsProvider) {
    return Expanded(
      child: ListView.builder(
        itemCount: betsProvider.bets.length,
        itemBuilder: (context, index) {
          final bet = betsProvider.bets[index];
          return betCard(context, bet);
        },
      ),
    );
  }

  Widget betCard(BuildContext context, bet) {
    return Card(
        color: const Color(0xFF282624),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: InkWell(
          hoverColor: const Color.fromARGB(255, 71, 68, 65),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Ícone à esquerda
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_esports,
                    color: _getStatusColor(bet.status),
                    size: 28,
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
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duração: ${bet.duration} dias',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
                          color: _getStatusColor(bet.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bet.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BetDetailsScreen(bet: bet),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  // Função para obter a cor do status
  static Color _getStatusColor(String status) {
    switch (status) {
      case 'Em Andamento':
        return Colors.green;
      case 'Encerrada':
        return Colors.red;
      case 'Agendada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
              color: const Color(0xFF282624),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 5),
              ],
            ),
            child: bet.status == 'Em Andamento'
                ? inProgressBet(context)
                : scheduleBet(context)));
  }

  Widget inProgressBet(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
        child: Text('Aposta ${bet.status}',
            style: TextStyle(
              fontSize: 18,
              // color: Color.fromARGB(255, 222, 159, 42), ),
              color: _BetsScreenState._getStatusColor('${bet.status}'),
            )),
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Início: ${DateFormat('dd/MM/yyyy').format(bet.initialDate ?? DateTime.now())}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Fim: ${DateFormat('dd/MM/yyyy').format(bet.finalDate ?? DateTime.now())}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BetDetailsScreen(bet: bet)),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _BetsScreenState._getStatusColor('${bet.status}'),
                    textStyle: const TextStyle(color: Color(0xFF282624))),
                child: const Text(
                  'Ver Detalhes',
                  style: TextStyle(color: Colors.white),
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
        child: Text('Próxima Aposta ${bet.status}',
            style: TextStyle(
              fontSize: 18,
              // color: Color.fromARGB(255, 222, 159, 42), ),
              color: _BetsScreenState._getStatusColor('${bet.status}'),
            )),
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Início: ${DateFormat('dd/MM/yyyy').format(bet.initialDate ?? DateTime.now())}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Fim: ${DateFormat('dd/MM/yyyy').format(bet.finalDate ?? DateTime.now())}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final participantData = {
                    'userId': userId,
                    'trainingBetId': bet.id,
                  };
                  await participantsProvider.create(participantData);

                  // if (participantsProvider._errorMessage == null) {}
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _BetsScreenState._getStatusColor('${bet.status}'),
                    textStyle: const TextStyle(
                        color: Color.fromARGB(255, 222, 159, 42))),
                child: const Text(
                  'Participar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    ]);
  }
}
