import 'dart:developer' as developer;

import 'package:firstflutterapp/interfaces/user.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends ChangeNotifier {
  User? user;
  String? token;
  final ApiService _apiService = ApiService();

  void onAuthenticationSuccess(Map<String, dynamic> json) async {
    user = User.fromJson(json['user']);
    token = json['token'];
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> json) async {
    user = User.fromJson(json);
    notifyListeners();
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenSaved = prefs.getString('auth_token');

    if (tokenSaved == null) {
      developer.log('Token non trouvé, utilisateur non connecté');
      return false;
    }

    if(user == null){
     var request = await _apiService.request(method: 'GET', endpoint: '/users/profile');
     user = User.fromJson(request.data);
     token = tokenSaved;
    }


    return token != null && user != null;
  }

  Future<bool> isAdmin() async {
      final prefs = await SharedPreferences.getInstance();
      final tokenSaved = prefs.getString('auth_token');

      if (tokenSaved == null) {
        developer.log('Token non trouvé, impossible de vérifier le rôle admin');
        return false;
      }
    try {
      // Décode le token pour accéder aux claims
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(tokenSaved);
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
      // if (decodedToken.containsKey('authorities')) {
      //   developer.log('Vérification du champ "authorities": ${decodedToken['authorities']}');
      //   var authorities = decodedToken['authorities'];
      //   if (authorities is List) {
      //     for (var auth in authorities) {
      //       if (auth is String && (auth.contains('admin') || auth.contains('ADMIN'))) {
      //         return true;
      //       } else if (auth is Map && auth.containsKey('authority')) {
      //         var authority = auth['authority'];
      //         if (authority is String && (authority.contains('admin') || authority.contains('ADMIN'))) {
      //           return true;
      //         }
      //       }
      //     }
      //   }
      // }
      developer.log('Aucun rôle admin trouvé dans le token');
      return false;
    } catch (e) {
      developer.log('Erreur lors du décodage du token: $e');
      return false;
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    user = null;
    token = null;
    developer.log('Utilisateur déconnecté');
  }
}
