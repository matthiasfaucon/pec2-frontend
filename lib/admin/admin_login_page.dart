import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/auth_utils.dart';
import '../utils/platform_utils.dart';
import '../utils/route_utils.dart';
import 'admin_dashboard.dart';
import 'dart:developer' as developer;

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _tokenDebugInfo = '';

  @override
  void initState() {
    super.initState();
    
    // Vérifie si l'utilisateur est sur le web, sinon affiche un message d'erreur
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
    } else {
      // Sur le web, vérifie si l'utilisateur est déjà connecté avec un rôle admin
      _checkAdminAccess();
    }
  }
  
  Future<void> _checkAdminAccess() async {
    final bool canAccess = await AuthUtils.canAccessAdminPanel();
    if (canAccess) {
      // Si déjà connecté avec un rôle admin, rediriger vers le dashboard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouteUtils.navigateToAdminDashboard(context);
      });
    }
  }

  Future<void> _loginAdmin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _tokenDebugInfo = '';
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await _apiService.request(
        method: 'POST',
        endpoint: '/login',
        body: {'email': email, 'password': password},
        withAuth: false,
      );
      
      final token = response.data['token'];
      developer.log('Token reçu: $token');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      
      // Déboguer le contenu du token
      await AuthUtils.debugToken();

      // Vérifie si l'utilisateur a le rôle admin
      final bool isAdmin = await AuthUtils.isAdmin();
      developer.log('L\'utilisateur est-il admin? $isAdmin');
      
      if (isAdmin) {
        // Redirige vers le tableau de bord admin
        RouteUtils.navigateToAdminDashboard(context);
      } else {
        // Si l'utilisateur n'est pas un admin, affiche un message d'erreur et le déconnecte
        await AuthUtils.logout();
        
        try {
          // Récupère et affiche le contenu du token pour le débogage
          final Map<String, dynamic> decodedToken = token != null ? 
              await Future.value(AuthUtils.debugToken()).then((_) => {}) :
              {};
          
          setState(() {
            _errorMessage = 'Vous n\'avez pas les droits administrateur nécessaires.';
            _tokenDebugInfo = 'Contenu du token pour débogage: \n${decodedToken.toString()}';
          });
        } catch (e) {
          setState(() {
            _errorMessage = 'Vous n\'avez pas les droits administrateur nécessaires.';
            _tokenDebugInfo = 'Erreur lors du décodage du token: $e';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      developer.log('Erreur de connexion: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration - OnlyFlick'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Connexion Administration",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email administrateur",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: const Color(0xFF6C3FFE)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mot de passe",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: const Color(0xFF6C3FFE)),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Color(0xFFFF3A30)),
                  ),
                ),
              if (_tokenDebugInfo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[200],
                    child: Text(
                      _tokenDebugInfo,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C3FFE)))
                : ElevatedButton(
                    onPressed: _loginAdmin,
                    child: const Text(
                      "Se connecter",
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
} 