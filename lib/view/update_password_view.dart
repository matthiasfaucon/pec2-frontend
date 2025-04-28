import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/auth_utils.dart';
import '../utils/platform_utils.dart';
import '../utils/route_utils.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({Key? key}) : super(key: key);

  @override
  _UpdatePasswordViewState createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    
    // Vérifie si l'utilisateur est sur le web, redirige vers l'interface admin
    if (PlatformUtils.isWebPlatform()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouteUtils.navigateToAdminLogin(context);
      });
      return;
    }
    
    // Vérifie si l'utilisateur est connecté
    _checkLoginStatus();
  }
  
  Future<void> _checkLoginStatus() async {
    final bool isLoggedIn = await AuthUtils.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) {
        RouteUtils.navigateToMobileHome(context);
      }
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Tous les champs sont obligatoires';
        _successMessage = '';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'Le nouveau mot de passe doit contenir au moins 6 caractères';
        _successMessage = '';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Les nouveaux mots de passe ne correspondent pas';
        _successMessage = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      await _apiService.request(
        method: 'PUT',
        endpoint: '/users/password',
        body: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        withAuth: true,
      );

      setState(() {
        _isLoading = false;
        _successMessage = 'Mot de passe mis à jour avec succès';
        // Réinitialiser les champs
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si nous sommes sur le web, ne pas afficher cette page
    if (PlatformUtils.isWebPlatform()) {
      return const Scaffold(
        body: Center(
          child: Text("Cette page n'est pas disponible sur le web."),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mettre à jour le mot de passe'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Modification du mot de passe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Ancien mot de passe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF6C3FFE)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureOldPassword = !_obscureOldPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Nouveau mot de passe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF6C3FFE)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Confirmer le nouveau mot de passe',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: const Color(0xFF6C3FFE)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Color(0xFFFF3A30)),
                  textAlign: TextAlign.center,
                ),
              ),
            
            if (_successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _successMessage,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 32),
            
            _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C3FFE)))
              : ElevatedButton(
                  onPressed: _updatePassword,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF6C3FFE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Mettre à jour mon mot de passe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
} 