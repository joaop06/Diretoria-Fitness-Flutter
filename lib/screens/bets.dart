import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:daily_training_flutter/screens/bet_details.dart';
import 'package:daily_training_flutter/services/bets_service.dart';
import 'package:daily_training_flutter/providers/bets_provider.dart';

class BetsScreen extends StatefulWidget {
  @override
  _BetsScreenState createState() => _BetsScreenState();
}

class _BetsScreenState extends State<BetsScreen> {
  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<BetsProvider>(context, listen: false).fetchBets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final betsProvider = Provider.of<BetsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1e1c1b),
      appBar: AppBar(
        title: const Text(
          'Apostas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF282624),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () => {Navigator.pushNamed(context, '/new_bet')},
          )
        ],
      ),
      body: betsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : betsProvider.bets.isNotEmpty
              ? Center(
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 500, maxWidth: 800),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (betsProvider.highlightedBet != null)
                            _HighlightedBet(bet: betsProvider.highlightedBet!),
                          const SizedBox(height: 60),
                          const Text(
                            'Outras Apostas',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          otherBets(context, betsProvider),
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                  'Nenhuma aposta disponível',
                  style: TextStyle(color: Colors.white),
                )),
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
                        'Aposta: ${bet.id}',
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
  final Bet bet;

  const _HighlightedBet({required this.bet});

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
                  // Ação para participar
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
