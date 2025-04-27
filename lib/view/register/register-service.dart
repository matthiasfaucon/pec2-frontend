import 'package:firstflutterapp/utils/check-form-data.dart';

class RegisterService {
  final CheckFormData _checkFormData = CheckFormData();

  bool isSamePassword(String password1, String password2) {
    return password1 == password2 && password1.trim() != "";
  }

  bool isValidPassword(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasMinimumString = password.length >= 6;

    return hasUpper && hasDigit && hasMinimumString;
  }

  String getMessageErrorPassword(String password, String confirmPassword) {
    final bool validPassword = isValidPassword(password);
    final bool samePassword = isSamePassword(password, confirmPassword);
    final bool notEmptyPassword = _checkFormData.inputIsNotEmptyOrNull(password);

    if(!notEmptyPassword){
      return "Le mot de passe doit être rempli";
    }else if(!samePassword){
      return "Les mots ne sont pas identiques";
    }else if(!validPassword){
      return "format incorrect";
    }else{
      return "format incorrect";
    }
  }

  checkStep1IsOk(
    String email,
    String password,
    String confirmPassword,
    String pseudo,
  ) {
    final bool validEmail = _checkFormData.validEmail(email);
    final bool samePassword = isSamePassword(password, confirmPassword);
    final bool validPassword = isValidPassword(password);
    final bool validPseudo = _checkFormData.inputIsNotEmptyOrNull(pseudo);
    return validEmail &&
        samePassword &&
        validPassword &&
        validEmail &&
        validPseudo;
  }

  checkStep2IsOk(
    String firstName,
    String lastName,
    DateTime? birthDay,
    String? sexe,
  ) {
    final bool validFirstname = _checkFormData.inputIsNotEmptyOrNull(firstName);
    final bool validLastName = _checkFormData.inputIsNotEmptyOrNull(lastName);
    final bool validBirthDay = _checkFormData.dateIsNotEmpty(birthDay);
    final bool validSexe = _checkFormData.inputIsNotEmptyOrNull(sexe);
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
