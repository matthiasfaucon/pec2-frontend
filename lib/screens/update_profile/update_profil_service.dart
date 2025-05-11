import '../../utils/check-form-data.dart';

class UpdateProfileService {
  final CheckFormData _checkFormData = CheckFormData();

  String getSexe(String? selectedSexe) {
    if (selectedSexe != null) {
      switch (selectedSexe) {
        case "WOMAN":
          return "Femme";
        case "MAN":
          return "Homme";
        case "OTHER":
          return "Autre";
        default:
          return "";
      }
    } else {
      return "";
    }
  }

  bool checkFormIsValid(
    String pseudo,
    String lastName,
    String firstName,
    DateTime? birthDay,
    String? sexe,
  ) {
    final bool validPseudo = _checkFormData.inputIsNotEmptyOrNull(pseudo);
    final bool validFirstname = _checkFormData.inputIsNotEmptyOrNull(firstName);
    final bool validLastName = _checkFormData.inputIsNotEmptyOrNull(lastName);
    final bool validBirthDay = _checkFormData.dateIsNotEmpty(birthDay);
    final bool validSexe = _checkFormData.inputIsNotEmptyOrNull(sexe);
    return validPseudo && validFirstname && validLastName && validBirthDay && validSexe;
  }

  String getErrorMessage(int status){
    switch(status){
      case 401:
        return "Vous n'êtes pas connecté";
      case 400:
        return "Données invalides";
      default:
        return "Impossible de faire les modifications";
    }
  }
}
