import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  // Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      developer.log('Token non trouvé, utilisateur non connecté');
      return false;
    }
    
    // Vérifie si le token est expiré
    try {
      final bool isExpired = JwtDecoder.isExpired(token);
      developer.log('Token expiré? $isExpired');
      return !isExpired;
    } catch (e) {
      developer.log('Erreur lors de la vérification de l\'expiration du token: $e');
      return false;
    }
  }

  
  // Affiche le contenu du token pour débogage
  static Future<void> debugToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      developer.log('Pas de token à déboguer');
      return;
    }
    
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      developer.log('DEBUG TOKEN: $decodedToken');
    } catch (e) {
      developer.log('Erreur lors du débogage du token: $e');
    }
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }
} 