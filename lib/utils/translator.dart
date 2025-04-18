class Translator {
  /// Traduit les constantes de sexe en français
  static String translateSexe(String? sexeValue) {
    if (sexeValue == null) return 'Non renseigné';
    
    switch (sexeValue.toUpperCase()) {
      case 'MAN':
        return 'Homme';
      case 'WOMAN':
        return 'Femme';
      case 'OTHER':
        return 'Autre';
      default:
        return sexeValue;
    }
  }
  
  /// Traduit les constantes de rôle en français
  static String translateRole(String? roleValue) {
    if (roleValue == null) return 'Non renseigné';
    
    switch (roleValue.toUpperCase()) {
      case 'ADMIN':
        return 'Administrateur';
      case 'USER':
        return 'Utilisateur';
  
      default:
        return roleValue;
    }
  }
  
  static String translateBoolean(bool? value) {
    if (value == null) return 'Non renseigné';
    return value ? 'Oui' : 'Non';
  }
  
  /// Traduit les booléens en Activé/Désactivé
  static String translateStatus(bool? value) {
    if (value == null) return 'Non renseigné';
    return value ? 'Activé' : 'Désactivé';
  }
} 