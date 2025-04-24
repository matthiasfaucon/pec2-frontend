import 'package:firstflutterapp/utils/check-form-data.dart';

class RegisterService {
  final CheckFormData _checkFormData = CheckFormData();

  bool validPassword(String password1, String password2) {
    return password1 == password2 && password1.trim() != "";
  }

  bool inputIsNotEmptyOrNull(String? input) {
    return input != null && input.trim() != "";
  }

  bool dateIsNotEmpty(DateTime? input) {
    return input != null;
  }

  checkStep1IsOk(
    String email,
    String password,
    String confirmPassword,
    String pseudo,
  ) {
    final bool validEmail = _checkFormData.validEmail(email);
    final bool isValidPassword = validPassword(password, confirmPassword);
    final bool validPseudo = inputIsNotEmptyOrNull(pseudo);
    return validEmail && isValidPassword && validEmail && validPseudo;
  }

  checkStep2IsOk(
    String firstName,
    String lastName,
    DateTime? birthDay,
    String? sexe,
  ) {
    final bool validFirstname = inputIsNotEmptyOrNull(firstName);
    final bool validLastName = inputIsNotEmptyOrNull(lastName);
    final bool validBirthDay = dateIsNotEmpty(birthDay);
    final bool validSexe = inputIsNotEmptyOrNull(sexe);
    return validFirstname && validLastName && validBirthDay && validSexe;
  }

  getSexe(String? selectedSexe) {
    if (selectedSexe != null) {
      switch (selectedSexe) {
        case "Femme":
          return "WOMAN";
        case "Homme":
          return "MAN";
        case "Autre":
          return "OTHER";
      }
    } else {
      return "";
    }
  }
}
