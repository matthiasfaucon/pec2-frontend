import 'package:firstflutterapp/interfaces/user.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:firstflutterapp/view/setting-user/setting-user.dart';
import 'package:firstflutterapp/view/update_profile/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/utils/platform_utils.dart';
import 'package:firstflutterapp/utils/route_utils.dart';
import 'package:firstflutterapp/utils/auth_utils.dart';
import 'dart:developer' as developer;
import 'update_password_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _userProfile = {};
  bool _isUpdating = false;


  @override
  void initState() {
    super.initState();

    // Vérifie si l'utilisateur est sur le web, redirige vers l'interface admin
    if (PlatformUtils.isWebPlatform()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouteUtils.navigateToAdminLogin(context);
        return;
      });
    } else {
      _fetchUserProfile();
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Vérifie si l'utilisateur est connecté
      final bool isLoggedIn = await AuthUtils.isLoggedIn();
      if (!isLoggedIn) {
        developer.log(
            'Utilisateur non connecté, redirection vers la page de connexion');
        RouteUtils.navigateToMobileHome(context);
        return;
      }

      final userData = await _apiService.request(
        method: 'GET',
        endpoint: '/users/profile',
        withAuth: true,
      );

      setState(() {
        _user = User.fromJson(userData.data);
        _isLoading = false;
      });
      developer.log('Profil utilisateur récupéré: $_user');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      developer.log('Erreur lors de la récupération du profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si nous sommes sur le web, ne pas afficher la page de profil mobile
    if (PlatformUtils.isWebPlatform()) {
      return const Scaffold(
        body: Center(
          child: Text("Cette page n'est pas disponible sur le web."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _user?.userName ?? 'Utilisateur',
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C3FFE)))
          : _errorMessage.isNotEmpty
          ? Center(child: Text("Erreur: $_errorMessage",
          style: const TextStyle(color: Color(0xFFFF3A30))))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final String avatarUrl = _userProfile['profilePicture'] ??
        'https://via.placeholder.com/150';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: const Color(0xFFE4DAFF),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("10", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("abonnements", style: TextStyle(fontSize: 10))
                ],
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("5", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("abonné(e)s", style: TextStyle(fontSize: 10))
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingUser()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 8),
          if (_userProfile['bio'] != null && _userProfile['bio']
              .toString()
              .isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _userProfile['bio'],
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  if(_user != null){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProfile(user: _user!)),
                    );
                  }
                },
                style: AppTheme.emptyButtonStyle,
                child: const Text(
                  "Modifier le profil",
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => UpdateProfile(user)),
                  // );
                },
                style: AppTheme.emptyButtonStyle,
                child: const Text(
                  "Statistiques",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatePasswordView()),
              );
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
            child: const Text(
              "Devenir créateur",
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.border_all)
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1),
          const SizedBox(height: 8),

          // _buildInfoCard("Informations personnelles", [
          //   _buildInfoRow("Pseudonyme", _userProfile['username'] ?? 'Non renseigné'),
          //   _buildInfoRow("Prénom", _userProfile['firstName'] ?? 'Non renseigné'),
          //   _buildInfoRow("Nom", _userProfile['lastName'] ?? 'Non renseigné'),
          //   _buildInfoRow("Email", _userProfile['email'] ?? 'Non renseigné'),
          //   _buildInfoRow("Date de naissance", DateFormatter.formatDate(_userProfile['birthDayDate'])),
          //   if (_userProfile['birthDayDate'] != null)
          //     _buildInfoRow("Âge", DateFormatter.calculateAge(_userProfile['birthDayDate'])),
          //   _buildInfoRow("Sexe", Translator.translateSexe(_userProfile['sexe'])),
          //   _buildInfoRow("Rôle", Translator.translateRole(_userProfile['role'])),
          // ]),
          //

        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C3FFE),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF6C3FFE)),
                  onPressed: () {
                    setState(() {
                      _isUpdating = true;
                    });
                  },
                ),
              ],
            ),
            const Divider(
              color: Color(0xFFE4DAFF),
              thickness: 1,
              height: 32,
            ),
            ...children,
          ],
        ),

      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
