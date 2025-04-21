import 'package:flutter/material.dart';
import '../utils/auth_utils.dart';
import '../utils/platform_utils.dart';
import '../utils/route_utils.dart';
import '../components/admin/admin_layout.dart';
import '../services/api_service.dart';
import 'dart:developer' as developer;

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  bool _isAdmin = false;
  int _selectedIndex = 0;
  List<dynamic> _users = [];
  bool _loadingUsers = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    setState(() {
      _isLoading = true;
    });

    if (!PlatformUtils.isWebPlatform()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("L'interface d'administration n'est disponible que sur le web."),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
      return;
    }

    final bool canAccess = await AuthUtils.canAccessAdminPanel();
    developer.log('Accès admin vérifié: $canAccess');
    
    setState(() {
      _isAdmin = canAccess;
      _isLoading = false;
    });

    if (!canAccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vous n'avez pas les droits administrateur nécessaires."),
            backgroundColor: Colors.red,
          ),
        );
        RouteUtils.navigateToAdminLogin(context);
      });
    }
  }

  Future<void> _logout() async {
    await AuthUtils.logout();
    RouteUtils.navigateToAdminLogin(context);
  }

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return const Scaffold(
        body: Center(child: Text("Accès non autorisé")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin OnlyFlick"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Déconnexion",
          ),
        ],
      ),
      body: AdminDashboardLayout(
        selectedIndex: _selectedIndex,
        onMenuItemSelected: _onMenuItemSelected,
        content: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildStatsContent();
      case 2:
        return _buildUsersContent();
      case 3:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tableau de bord",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildKpiCard(
                "Utilisateurs actifs",
                "128",
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(width: 24),
              _buildKpiCard(
                "Revenus mensuels",
                "2,540 €",
                Icons.euro,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    return const Center(
      child: Text(
        "Page Statistiques en développement",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildUsersContent() {
    // Charger automatiquement les utilisateurs si la liste est vide
    if (_users.isEmpty && !_loadingUsers) {
      Future.microtask(() => _fetchUsers());
    }
    
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
                          // Vérifier que l'utilisateur est un Map pour éviter les erreurs
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
                                  user['username'] != null && (user['username'] as String).isNotEmpty 
                                      ? (user['username'] as String)[0].toUpperCase() 
                                      : 'U',
                                  style: TextStyle(color: Colors.blue.shade800),
                                ),
                              ),
                              title: Text(
                                user['username'] as String? ?? 'Utilisateur inconnu',
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
    
    // ID utilisateur
    if (user['id'] != null) {
      details.add(_buildDetailRow('ID', user['id'].toString()));
    }
    
    // Nom et prénom
    if (user['firstName'] != null || user['lastName'] != null) {
      final firstName = user['firstName'] as String? ?? '';
      final lastName = user['lastName'] as String? ?? '';
      details.add(_buildDetailRow('Nom complet', '$firstName $lastName'));
    }
    
    // Date de naissance
    if (user['birthDayDate'] != null) {
      details.add(_buildDetailRow('Date de naissance', _formatDate(user['birthDayDate'])));
    }
    
    // Sexe
    if (user['sexe'] != null) {
      details.add(_buildDetailRow('Sexe', user['sexe']));
    }
    
    // Bio
    if (user['bio'] != null) {
      details.add(_buildDetailRow('Bio', user['bio']));
    }
    
    // Abonnement et paiement
    if (user['subscriptionPrice'] != null) {
      details.add(_buildDetailRow('Prix abonnement', '${user['subscriptionPrice']} €'));
    }
    
    if (user['stripeCustomerId'] != null) {
      details.add(_buildDetailRow('ID Stripe', user['stripeCustomerId']));
    }
    
    // Statut du compte
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
    
    // Vérification email
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
        details.add(_buildDetailRow('Vérifié le', emailVerified['time']));
      }
    }
    
    // Date de création
    if (user['createdAt'] != null) {
      details.add(_buildDetailRow('Créé le', _formatDate(user['createdAt'])));
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
      // Récupérer le token JWT pour l'authentification
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

      // Utiliser ApiService pour appeler la route backend
      final response = await ApiService().request(
        method: 'GET',
        endpoint: '/users', // Endpoint pour récupérer tous les utilisateurs
        withAuth: true, // Utilise le token stocké dans les SharedPreferences
      );

      // Vérifier que la réponse est bien une liste
      if (response is List) {
        setState(() {
          _users = response;
          _loadingUsers = false;
        });
      } else {
        // Si la réponse n'est pas une liste, essayons de voir si c'est un objet avec une propriété contenant la liste
        if (response is Map<String, dynamic>) {
          // Vérifier les clés courantes comme "data", "users", "results", etc.
          final possibleListKeys = ['data', 'users', 'results', 'items', 'content'];
          
          for (final key in possibleListKeys) {
            if (response.containsKey(key) && response[key] is List) {
              setState(() {
                _users = response[key];
                _loadingUsers = false;
              });
              return;
            }
          }
        }
        
        // Aucune liste trouvée
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

  Widget _buildSettingsContent() {
    return const Center(
      child: Text(
        "Page Paramètres en développement",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Formater la date pour l'affichage
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
} 