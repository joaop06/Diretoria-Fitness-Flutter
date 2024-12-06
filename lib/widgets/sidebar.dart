import 'package:daily_training_flutter/services/auth_service.dart';
import 'package:daily_training_flutter/services/users_service.dart';
import 'package:daily_training_flutter/utils/colors.dart';
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
  bool _isLoading = true;

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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AllColors.background,
      appBar: AppBar(
        backgroundColor: AllColors.black,
        elevation: 4,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            color: AllColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: _buildLeadingAvatar(),
      ),
      drawer: _buildDrawer(),
      body: body ??
          const Center(
            child: CircularProgressIndicator(
              color: AllColors.orange,
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
            color: AllColors.transparent,
            border: Border.all(
              color: AllColors.gold, // Cor da borda
              width: 2, // Largura da borda
            ),
            image: userImageUrl != null
                ? DecorationImage(
                    image: NetworkImage(userImageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AllColors.transparent,
            child: userImageUrl == null
                ? Text(
                    (userName?.isNotEmpty == true
                        ? userName![0].toUpperCase()
                        : "?"),
                    style: const TextStyle(
                      fontSize: 20,
                      color: AllColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : ClipOval(
                    child: Image.network(
                      userImageUrl,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.05,
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
          )),
    );
  }

  Widget _buildDrawer() {
    String? userName = userData?.name;
    String? userImageUrl = userData?.profileImagePath;

    return Drawer(
      backgroundColor: AllColors.card,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AllColors.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta o tamanho ao conteúdo
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centraliza verticalmente
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centraliza horizontalmente
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AllColors.transparent,
                    border: Border.all(
                      color: AllColors.gold, // Cor da borda
                      width: 2, // Largura da borda
                    ),
                    image: userImageUrl != null
                        ? DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(userImageUrl),
                          )
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AllColors.transparent,
                    backgroundImage: userImageUrl != null
                        ? NetworkImage(userImageUrl)
                        : null,
                    child: userImageUrl == null
                        ? Text(
                            userName != null && userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 30,
                              color: AllColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : null,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Text(
                  userName!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AllColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          _buildListTile(
            icon: Icons.home,
            title: "Início",
            onTap: () {
              Navigator.pushNamed(context, '/bets');
            },
          ),
          const Divider(color: AllColors.softBlack, thickness: 1),
          _buildListTile(
            icon: Icons.edit,
            title: "Editar Dados",
            onTap: () {
              Navigator.pushNamed(context, '/edit-user');
            },
          ),
          const Divider(color: AllColors.softBlack, thickness: 1),
          _buildListTile(
            icon: Icons.add,
            title: "Nova Aposta",
            onTap: () {
              Navigator.pushNamed(context, '/new-bet');
            },
          ),
          const Divider(color: AllColors.softBlack, thickness: 1),
          _buildListTile(
            icon: Icons.leaderboard,
            title: "Ranking",
            onTap: () {
              Navigator.pushNamed(context, '/ranking');
            },
          ),
          const Divider(color: AllColors.softBlack, thickness: 1),
          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
          const Divider(color: AllColors.softBlack, thickness: 2),
          _buildListTile(
            icon: Icons.logout,
            title: "Sair",
            onTap: () async {
              // SignUp
              await AuthService.signup(context);
            },
          )
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AllColors.white),
      title: Text(
        title,
        style: const TextStyle(color: AllColors.white),
      ),
      onTap: onTap,
    );
  }
}
