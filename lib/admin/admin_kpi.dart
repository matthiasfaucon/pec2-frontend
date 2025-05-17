import 'package:flutter/material.dart';

class AdminKpiDashboard extends StatefulWidget {
  const AdminKpiDashboard({Key? key}) : super(key: key);

  @override
  State<AdminKpiDashboard> createState() => _AdminKpiDashboardState();
}

class _AdminKpiDashboardState extends State<AdminKpiDashboard> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // TODO: Implement API call to fetch users
    setState(() {
      _users = [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return AdminKPI(users: _users);
  }
}

class AdminKPI extends StatelessWidget {
  final List<dynamic> users;
  
  const AdminKPI({
    Key? key,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcul des KPIs
    final totalUsers = users.length;
    final activeUsers = users.where((user) => user['enable'] == true).length;
    final adminUsers = users.where((user) => user['role'] == 'ADMIN').length;
    final subscribedUsers = users.where((user) => user['subscriptionEnable'] == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques Générales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildKPICard(
                title: 'Utilisateurs Totaux',
                value: totalUsers.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              _buildKPICard(
                title: 'Utilisateurs Actifs',
                value: activeUsers.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              _buildKPICard(
                title: 'Administrateurs',
                value: adminUsers.toString(),
                icon: Icons.admin_panel_settings,
                color: Colors.orange,
              ),
              _buildKPICard(
                title: 'Abonnés',
                value: subscribedUsers.toString(),
                icon: Icons.star,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
