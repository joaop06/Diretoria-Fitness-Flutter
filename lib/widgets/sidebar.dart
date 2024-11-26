import 'package:daily_training_flutter/services/auth_service.dart';
import 'package:daily_training_flutter/services/users_service.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  Object body;
  String title;
  Sidebar({Key? key, required this.title, required this.body})
      : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with AutomaticKeepAliveClientMixin {
  var body;
  var title = '';
  User? userData;

  @override
  bool get wantKeepAlive => true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      body = widget.body;
      title = widget.title;

      // Fetch user data
      userData = await _safeGetUserData();

      // Update loading state
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao buscar dados')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1e1c1b),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 12, 12),
        elevation: 4,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: _buildLeadingAvatar(),
      ),
      drawer: _buildDrawer(),
      body: body ??
          const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFCCA253),
            ),
          ),
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
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text("Início", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/bets');
            },
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
}
