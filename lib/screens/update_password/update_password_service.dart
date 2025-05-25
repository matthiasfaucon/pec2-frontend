class UpdatePasswordService {
  String getMessageError(String message) {
    switch (message) {
      case "User not found":
        return "Utilisateur non trouvé";
      case "The new password must contain at least 6 characters":
        return "Le mot de passe doit contenir au moins 6 caractères";
      case "The new password must be different from the old password":
        return "Le nouveau mot de passe être différent de l'ancien mot de passe";
      case "Incorrect old password":
        return "Ancien mot de passe incorrect";
      default:
        return 'Erreur lors de la connexion';
    }
  }
}