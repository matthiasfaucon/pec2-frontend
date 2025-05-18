class LoginService {

  String getMessageError(String message) {
    switch (message) {
      case "User not found":
        return "Utilisateur non trouvé";
      case "Wrong credentials":
        return "L'email et le mot de passe ne correspondent pas";
      case "user don't valid email":
        return "Email non validé";
      default:
        return 'Erreur lors de la connexion';
    }
  }
}
