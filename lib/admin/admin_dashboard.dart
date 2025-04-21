import 'package:flutter/material.dart';
import '../utils/auth_utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    setState(() {
      _isLoading = true;
    });

    // Vérifier si l'utilisateur est sur le web
    if (!kIsWeb) {
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

    // Vérifier si l'utilisateur est un admin
    final bool canAccess = await AuthUtils.canAccessAdminPanel();
    
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
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _logout() async {
    await AuthUtils.logout();
    Navigator.of(context).pushReplacementNamed('/admin-login');
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
        title: const Text("Tableau de bord admin"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Déconnexion",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6C3FFE),
              ),
              child: Text(
                'Administration OnlyFlick',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gestion utilisateurs'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers la page de gestion des utilisateurs
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Gestion produits'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers la page de gestion des produits
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers la page des paramètres
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bienvenue dans l'interface d'administration",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Statistiques générales",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard("Utilisateurs", "250", Icons.people, Colors.blue),
                  _buildStatCard("Produits", "120", Icons.inventory_2, Colors.green),
                  _buildStatCard("Commandes", "48", Icons.shopping_cart, Colors.orange),
                  _buildStatCard("Revenus", "9,540 €", Icons.euro, Colors.purple),
                  _buildStatCard("Visites", "1,250", Icons.visibility, Colors.teal),
                  _buildStatCard("Taux de conversion", "3.2%", Icons.trending_up, Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
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
                fontSize: 24,
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
    );
  }
} 