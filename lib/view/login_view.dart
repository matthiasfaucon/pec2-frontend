import 'dart:developer' as developer;
import 'package:firstflutterapp/view/register/register_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/platform_utils.dart';
import '../utils/route_utils.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    if (PlatformUtils.isWebPlatform()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouteUtils.navigateToAdminLogin(context);
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
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
      developer.log('Mobile login - Token reçu: $token');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);

      if (PlatformUtils.isWebPlatform()) {
        RouteUtils.navigateToAdminLogin(context);
      } else {
        RouteUtils.navigateToMobileHome(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      developer.log('Erreur login: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWebPlatform()) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Vous êtes sur la version web de l'application.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                "Redirection vers l'interface admin...",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  RouteUtils.navigateToAdminLogin(context);
                },
                child: const Text("Accéder à l'interface admin"),
              ),
            ],
          ),
        ),
      );
    }

    // Interface de connexion mobile standard
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Ravis de vous revoir sur",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                "OnlyFlick",
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
                  "Pseudo ou email",
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
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Pas de compte ?",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterView()),
                  );                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("S'inscrire"),
              ),
              const Spacer(),
              const SizedBox(height: 20),
              _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C3FFE)))
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      "Se connecter",
                    ),
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
