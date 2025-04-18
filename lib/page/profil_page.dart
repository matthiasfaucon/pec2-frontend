import 'package:flutter/material.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _userProfile = {};

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userData = await _apiService.request(
        method: 'GET',
        endpoint: '/users/profile',
        withAuth: true,
      );
      
      setState(() {
        _userProfile = userData;
        _isLoading = false;
      });
      print('Profil utilisateur: $_userProfile');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Erreur lors de la récupération du profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty
          ? Center(child: Text("Erreur: $_errorMessage", style: TextStyle(color: Colors.red)))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final String avatarUrl = _userProfile['profilePicture'] ?? 'https://via.placeholder.com/150';
    final String fullName = '${_userProfile['firstName'] ?? ''} ${_userProfile['lastName'] ?? ''}';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(height: 24),
          Text(
            fullName.trim().isNotEmpty ? fullName : (_userProfile['username'] ?? 'Utilisateur'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _userProfile['email'] ?? '',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          if (_userProfile['bio'] != null && _userProfile['bio'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _userProfile['bio'],
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 32),
          _buildInfoCard("Informations personnelles", [
            _buildInfoRow("Nom d'utilisateur", _userProfile['username'] ?? 'Non renseigné'),
            _buildInfoRow("Prénom", _userProfile['firstName'] ?? 'Non renseigné'),
            _buildInfoRow("Nom", _userProfile['lastName'] ?? 'Non renseigné'),
            _buildInfoRow("Email", _userProfile['email'] ?? 'Non renseigné'),
            _buildInfoRow("Date de naissance", _formatDate(_userProfile['birthDayDate'])),
            _buildInfoRow("Sexe", _userProfile['sexe'] ?? 'Non renseigné'),
            _buildInfoRow("Rôle", _userProfile['role'] ?? 'Non renseigné'),
            _buildInfoRow("Créé le", _formatDate(_userProfile['createdAt'])),
            _buildInfoRow("Mis à jour le", _formatDate(_userProfile['updatedAt'])),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard("Statut du compte", [
            _buildInfoRow("Compte activé", _userProfile['enable'] == true ? 'Oui' : 'Non'),
            _buildInfoRow("Abonnement", _userProfile['subscriptionEnable'] == true ? 'Activé' : 'Désactivé'),
            _buildInfoRow("Commentaires", _userProfile['commentsEnable'] == true ? 'Activés' : 'Désactivés'),
            _buildInfoRow("Messages", _userProfile['messageEnable'] == true ? 'Activés' : 'Désactivés'),
            if (_userProfile['emailVerifiedAt'] != null)
              _buildInfoRow("Email vérifié", "Oui (${_formatDate(_userProfile['emailVerifiedAt']['Time'])})"),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'Non disponible';
    try {
      final String cleanDate = dateString.toString().replaceAll('T', ' ');
      final DateTime date = DateTime.parse(cleanDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      print('Erreur de format de date: $e pour $dateString');
      return 'Format de date invalide';
    }
  }
}
