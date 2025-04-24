import 'package:flutter/material.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/utils/date_formatter.dart';
import 'package:firstflutterapp/utils/translator.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _userProfile = {};

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
        developer.log('Utilisateur non connecté, redirection vers la page de connexion');
        RouteUtils.navigateToMobileHome(context);
        return;
      }
      
      final userData = await _apiService.request(
        method: 'GET',
        endpoint: '/users/profile',
        withAuth: true,
      );
      
      setState(() {
        _userProfile = userData.data;
        _isLoading = false;
      });
      developer.log('Profil utilisateur récupéré: $_userProfile');
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
        title: const Text("Mon Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C3FFE)))
        : _errorMessage.isNotEmpty
          ? Center(child: Text("Erreur: $_errorMessage", style: const TextStyle(color: Color(0xFFFF3A30))))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final String avatarUrl = _userProfile['profilePicture'] ?? 'https://via.placeholder.com/150';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: const Color(0xFFE4DAFF),
          ),
          const SizedBox(height: 24),
          Text(
            _userProfile['username'] ?? 'Utilisateur',
            style: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.black
            ),
          ),
          
          if (_userProfile['bio'] != null && _userProfile['bio'].toString().isNotEmpty)
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
          _buildInfoCard("Informations personnelles", [
            _buildInfoRow("Pseudonyme", _userProfile['username'] ?? 'Non renseigné'),
            _buildInfoRow("Prénom", _userProfile['firstName'] ?? 'Non renseigné'),
            _buildInfoRow("Nom", _userProfile['lastName'] ?? 'Non renseigné'),
            _buildInfoRow("Email", _userProfile['email'] ?? 'Non renseigné'),
            _buildInfoRow("Date de naissance", DateFormatter.formatDate(_userProfile['birthDayDate'])),
            if (_userProfile['birthDayDate'] != null)
              _buildInfoRow("Âge", DateFormatter.calculateAge(_userProfile['birthDayDate'])),
            _buildInfoRow("Sexe", Translator.translateSexe(_userProfile['sexe'])),
            _buildInfoRow("Rôle", Translator.translateRole(_userProfile['role'])),
          ]),
          
          const SizedBox(height: 16),
          
          _buildInfoCard("Informations du compte", [
            _buildInfoRow("Créé le", DateFormatter.formatDate(_userProfile['createdAt'])),
            _buildInfoRow("Mis à jour le", DateFormatter.formatDate(_userProfile['updatedAt'])),
          ]),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatePasswordView()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF6C3FFE),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Mettre à jour mon mot de passe",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bouton de déconnexion
          OutlinedButton(
            onPressed: () async {
              await AuthUtils.logout();
              if (context.mounted) {
                RouteUtils.navigateToMobileHome(context);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[300]!),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Se déconnecter",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C3FFE),
              ),
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
