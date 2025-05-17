abstract class Validator {
  String? validate(String? value);
}

class RequiredValidator implements Validator {
  @override
  String? validate(String? value) {

    if (value == null || value.isEmpty) {
      return 'Vous devez remplir ce champs';
    }

    return null;
  }
}

class EmailValidator implements Validator {
  @override
  String? validate(String? value) {
    if(value == null){
      return 'Email non valide';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email non valide';
    }
    return null;
  }
}
