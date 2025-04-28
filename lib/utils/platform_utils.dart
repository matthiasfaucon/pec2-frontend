import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlatformUtils {
  // Détermine l'URL de l'API en fonction de la plateforme
  static String getApiBaseUrl() {
    if (kIsWeb) {
      return dotenv.env['API_BASE_URL_WEB'] ?? 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      return dotenv.env['API_BASE_URL_ANDROID'] ?? 'http://10.0.2.2:8080';
    } else {
      return dotenv.env['API_BASE_URL_DEFAULT'] ?? 'http://localhost:8080';
    }
  }
  
  // Vérifie si l'application s'exécute sur le web
  static bool isWebPlatform() {
    return kIsWeb;
  }
  
  // Vérifie si l'application s'exécute sur Android
  static bool isAndroidPlatform() {
    return !kIsWeb && Platform.isAndroid;
  }
  
  // Vérifie si l'application s'exécute sur iOS
  static bool isIOSPlatform() {
    return !kIsWeb && Platform.isIOS;
  }
  
  // Retourne une chaîne indiquant la plateforme actuelle
  static String getCurrentPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'other';
    }
  }
  
  // Log des informations sur la plateforme pour le débogage
  static void logPlatformInfo() {
    developer.log('Plateforme: ${getCurrentPlatform()}');
    developer.log('URL API: ${getApiBaseUrl()}');
  }
} 