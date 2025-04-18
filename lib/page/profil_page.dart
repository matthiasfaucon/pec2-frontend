import 'package:flutter/material.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/utils/date_formatter.dart';
import 'package:firstflutterapp/utils/translator.dart';

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
      print('User profile: $_userProfile');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error fetching profile: $e');
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
            _userProfile['username'] ?? 'Utilisateur',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
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
            _buildInfoRow("Pseudonyme", _userProfile['username'] ?? 'Non renseigné'),
            _buildInfoRow("Prénom", _userProfile['firstName'] ?? 'Non renseigné'),
            _buildInfoRow("Nom", _userProfile['lastName'] ?? 'Non renseigné'),
            _buildInfoRow("Email", _userProfile['email'] ?? 'Non renseigné'),
            _buildInfoRow("Date de naissance", DateFormatter.formatDate(_userProfile['birthDayDate'])),
            if (_userProfile['birthDayDate'] != null)
              _buildInfoRow("Âge", DateFormatter.calculateAge(_userProfile['birthDayDate'])),
            _buildInfoRow("Sexe", Translator.translateSexe(_userProfile['sexe'])),
            _buildInfoRow("Rôle", Translator.translateRole(_userProfile['role'])),
            _buildInfoRow("Créé le", DateFormatter.formatDate(_userProfile['createdAt'])),
            _buildInfoRow("Mis à jour le", DateFormatter.formatDate(_userProfile['updatedAt'])),
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
}
