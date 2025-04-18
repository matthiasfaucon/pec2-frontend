import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(dynamic dateString) {
    if (dateString == null) return 'Non disponible';
    
    try {
      final String cleanDate = dateString.toString().replaceAll('T', ' ');
      final DateTime date = DateTime.parse(cleanDate);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      print('Erreur de format de date: $e pour $dateString');
      return 'Format de date invalide';
    }
  }

  static String formatDateTime(dynamic dateString) {
    if (dateString == null) return 'Non disponible';
    
    try {
      final String cleanDate = dateString.toString().replaceAll('T', ' ');
      final DateTime date = DateTime.parse(cleanDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      print('Erreur de format de date: $e pour $dateString');
      return 'Format de date invalide';
    }
  }

  static String formatLongDate(dynamic dateString) {
    if (dateString == null) return 'Non disponible';
    
    try {
      final String cleanDate = dateString.toString().replaceAll('T', ' ');
      final DateTime date = DateTime.parse(cleanDate);
      return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      print('Erreur de format de date: $e pour $dateString');
      return 'Format de date invalide';
    }
  }

  static String calculateAge(dynamic birthDateString) {
    if (birthDateString == null) return 'Non disponible';
    
    try {
      final String cleanDate = birthDateString.toString().replaceAll('T', ' ');
      final DateTime birthDate = DateTime.parse(cleanDate);
      final DateTime today = DateTime.now();
      
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      
      return '$age ans';
    } catch (e) {
      print('Erreur de calcul d\'âge: $e pour $birthDateString');
      return 'Non disponible';
    }
  }
} 