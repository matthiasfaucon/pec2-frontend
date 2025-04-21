import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;

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
  
  // Vérifie si l'utilisateur est un administrateur
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) {
      developer.log('Token non trouvé, impossible de vérifier le rôle admin');
      return false;
    }
    
    try {
      // Décode le token pour accéder aux claims
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      developer.log('Token décodé: $decodedToken');
      
      // Vérification exhaustive du rôle admin dans différents formats possibles
      if (decodedToken.containsKey('role')) {
        developer.log('Vérification du champ "role": ${decodedToken['role']}');
        if (decodedToken['role'] == 'admin' || decodedToken['role'] == 'ADMIN') {
          return true;
        }
      }
      
      if (decodedToken.containsKey('roles')) {
        developer.log('Vérification du champ "roles": ${decodedToken['roles']}');
        var roles = decodedToken['roles'];
        if (roles is List && (roles.contains('admin') || roles.contains('ADMIN'))) {
          return true;
        } else if (roles is String && (roles == 'admin' || roles == 'ADMIN')) {
          return true;
        }
      }
      
      // Vérification supplémentaire pour les formats avec "authorities"
      if (decodedToken.containsKey('authorities')) {
        developer.log('Vérification du champ "authorities": ${decodedToken['authorities']}');
        var authorities = decodedToken['authorities'];
        if (authorities is List) {
          for (var auth in authorities) {
            if (auth is String && (auth.contains('admin') || auth.contains('ADMIN'))) {
              return true;
            } else if (auth is Map && auth.containsKey('authority')) {
              var authority = auth['authority'];
              if (authority is String && (authority.contains('admin') || authority.contains('ADMIN'))) {
                return true;
              }
            }
          }
        }
      }
      
      // Si aucune condition n'est remplie, l'utilisateur n'est pas admin
      developer.log('Aucun rôle admin trouvé dans le token');
      return false;
    } catch (e) {
      developer.log('Erreur lors du décodage du token: $e');
      return false;
    }
  }
  
  // Vérifie si l'utilisateur peut accéder à l'interface admin
  static Future<bool> canAccessAdminPanel() async {
    // L'accès à l'interface d'administration est limité au web
    if (!kIsWeb) {
      developer.log('Accès refusé: pas sur une plateforme web');
      return false;
    }
    
    // En plus, l'utilisateur doit être un administrateur
    final bool isAdmin = await AuthUtils.isAdmin();
    developer.log('Est admin? $isAdmin');
    return isAdmin;
  }
  
  // Déconnecte l'utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    developer.log('Utilisateur déconnecté');
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