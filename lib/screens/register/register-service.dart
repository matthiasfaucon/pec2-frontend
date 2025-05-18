import 'package:firstflutterapp/utils/check-form-data.dart';

class RegisterService {
  final CheckFormData _checkFormData = CheckFormData();

  bool checkStep2IsOk(DateTime? birthDay, String? sexe) {
    final bool validBirthDay = isValidBirthdate(birthDay);
    final bool validSexe = isValidSexe(sexe);
    return validBirthDay && validSexe;
  }

  bool isValidBirthdate(DateTime? birthDay){
    return _checkFormData.dateIsNotEmpty(birthDay);
  }

  bool isValidSexe(String? sexe){
    return _checkFormData.inputIsNotEmptyOrNull(sexe);
  }

  String getSexe(String? selectedSexe) {
    if (selectedSexe != null) {
      switch (selectedSexe) {
        case "Femme":
          return "WOMAN";
        case "Homme":
          return "MAN";
        case "Autre":
          return "OTHER";
        default: return "MAN";
      }
    } else {
      return "MAN";
    }
  }

  String getMessageError(String message) {
    switch (message) {
      case 'This username is already taken':
        return 'Pseudo déjà utilisé';
      case 'This email is already used':
        return 'Email déjà utilisé';
      default:
        return "Erreur lors de l'inscription";
    }
  }
}
