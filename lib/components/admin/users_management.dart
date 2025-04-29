import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/auth_utils.dart';
import '../../utils/date_formatter.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({Key? key}) : super(key: key);

  @override
  _UsersManagementState createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  List<dynamic> _users = [];
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gestion des utilisateurs",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _fetchUsers,
                icon: Icon(_loadingUsers ? Icons.hourglass_empty : Icons.refresh),
                label: Text(_loadingUsers ? "Chargement..." : "Actualiser"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loadingUsers
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text("Aucun utilisateur trouvé", style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchUsers,
                              child: const Text("Essayer à nouveau"),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          if (user is! Map) {
                            return ListTile(
                              title: Text("Format d'utilisateur invalide"),
                              subtitle: Text("Données: $user"),
                            );
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  user['userName'] != null && (user['userName'] as String).isNotEmpty
                                      ? (user['userName'] as String)[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                              ),
                              title: Text(
                                user['userName'] as String? ?? 'Utilisateur inconnu',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(user['email'] as String? ?? 'Email non disponible'),
                              trailing: Chip(
                                backgroundColor: user['role'] == 'ADMIN' ? Colors.red.shade100 : Colors.green.shade100,
                                label: Text(
                                  user['role'] as String? ?? 'Utilisateur',
                                  style: TextStyle(
                                    color: user['role'] == 'ADMIN' ? Colors.red.shade800 : Colors.green.shade800,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _buildUserDetailsList(user),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserDetailsList(Map<dynamic, dynamic> user) {
    List<Widget> details = [];
    
    if (user['id'] != null) {
      details.add(_buildDetailRow('ID', user['id'].toString()));
    }
    
    if (user['firstName'] != null || user['lastName'] != null) {
      final firstName = user['firstName'] as String? ?? '';
      final lastName = user['lastName'] as String? ?? '';
      details.add(_buildDetailRow('Nom complet', '$firstName $lastName'));
    }
    
    if (user['birthDayDate'] != null) {
      details.add(_buildDetailRow('Date de naissance', DateFormatter.formatDate(user['birthDayDate'])));
      details.add(_buildDetailRow('Âge', DateFormatter.calculateAge(user['birthDayDate'])));
    }
    
    if (user['sexe'] != null) {
      details.add(_buildDetailRow('Sexe', user['sexe']));
    }
    
    if (user['bio'] != null) {
      details.add(_buildDetailRow('Bio', user['bio']));
    }
    
    if (user['subscriptionPrice'] != null) {
      details.add(_buildDetailRow('Prix abonnement', '${user['subscriptionPrice']} €'));
    }
    
    if (user['stripeCustomerId'] != null) {
      details.add(_buildDetailRow('ID Stripe', user['stripeCustomerId']));
    }
    
    final List<Widget> statusWidgets = [];
    
    if (user['enable'] != null) {
      final bool enabled = user['enable'] == true;
      statusWidgets.add(
        Chip(
          backgroundColor: enabled ? Colors.green.shade100 : Colors.red.shade100,
          label: Text(
            enabled ? 'Compte activé' : 'Compte désactivé',
            style: TextStyle(
              color: enabled ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ),
      );
    }
    
    if (user['subscriptionEnable'] != null) {
      final bool subEnabled = user['subscriptionEnable'] == true;
      statusWidgets.add(
        Chip(
          backgroundColor: subEnabled ? Colors.green.shade100 : Colors.orange.shade100,
          label: Text(
            subEnabled ? 'Abonnement actif' : 'Pas d\'abonnement',
            style: TextStyle(
              color: subEnabled ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ),
      );
    }
    
    if (user['commentsEnable'] != null) {
      final bool commentsEnabled = user['commentsEnable'] == true;
      statusWidgets.add(
        Chip(
          backgroundColor: commentsEnabled ? Colors.green.shade100 : Colors.grey.shade300,
          label: Text(
            commentsEnabled ? 'Commentaires activés' : 'Commentaires désactivés',
            style: TextStyle(
              color: commentsEnabled ? Colors.green.shade800 : Colors.grey.shade800,
            ),
          ),
        ),
      );
    }
    
    if (user['messageEnable'] != null) {
      final bool messagesEnabled = user['messageEnable'] == true;
      statusWidgets.add(
        Chip(
          backgroundColor: messagesEnabled ? Colors.green.shade100 : Colors.grey.shade300,
          label: Text(
            messagesEnabled ? 'Messages activés' : 'Messages désactivés',
            style: TextStyle(
              color: messagesEnabled ? Colors.green.shade800 : Colors.grey.shade800,
            ),
          ),
        ),
      );
    }
    
    if (statusWidgets.isNotEmpty) {
      details.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statut du compte:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: statusWidgets),
          ],
        ),
      );
    }
    
    if (user['emailVerified'] != null && user['emailVerified'] is Map) {
      final emailVerified = user['emailVerified'] as Map;
      final bool isVerified = emailVerified['valid'] == true;
      
      details.add(
        Chip(
          backgroundColor: isVerified ? Colors.green.shade100 : Colors.orange.shade100,
          label: Text(
            isVerified ? 'Email vérifié' : 'Email non vérifié',
            style: TextStyle(
              color: isVerified ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ),
      );
      
      if (emailVerified['time'] != null) {
        details.add(_buildDetailRow('Vérifié le', DateFormatter.formatDateTime(emailVerified['time'])));
      }
    }
    
    if (user['createdAt'] != null) {
      details.add(_buildDetailRow('Créé le', DateFormatter.formatDateTime(user['createdAt'])));
    }

    if (user['tokenVerificationEmail'] != null) {
      final token = user['tokenVerificationEmail'].toString();
      details.add(_buildDetailRow(
        'Token de vérification', 
        token.length > 20 ? '${token.substring(0, 20)}...' : token
      ));
    }
    
    return details;
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loadingUsers = true;
    });

    try {
      final token = await AuthUtils.getToken();
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur d'authentification"), backgroundColor: Colors.red),
        );
        setState(() {
          _loadingUsers = false;
        });
        return;
      }

      final response = await ApiService().request(
        method: 'GET',
        endpoint: '/users', // Endpoint pour récupérer tous les utilisateurs
        withAuth: true, // Utilise le token stocké dans les SharedPreferences
      );

      if (response.data is List) {
        setState(() {
          _users = response.data;
          _loadingUsers = false;
        });
      } else {
        if (response.data is Map<String, dynamic>) {
          final possibleListKeys = ['data', 'users', 'results', 'items', 'content'];
          
          for (final key in possibleListKeys) {
            if (response.data.containsKey(key) && response[key] is List) {
              setState(() {
                _users = response.data[key];
                _loadingUsers = false;
              });
              return;
            }
          }
        }
        
        developer.log('Réponse reçue mais pas au format attendu: $response');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Format de réponse inattendu de l'API"),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _users = [];
          _loadingUsers = false;
        });
      }
    } catch (error) {
      developer.log('Erreur lors de la récupération des utilisateurs: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $error"), backgroundColor: Colors.red),
      );
      setState(() {
        _users = [];
        _loadingUsers = false;
      });
    }
  }
} 