abstract class Validator {
  String? validate(String value);
}

class RequiredValidator implements Validator {
  @override
  String? validate(String value) {
    if (value.isEmpty) {
      return 'Vous devez remplir ce champs';
    }

    return null;
  }
}

class EmailValidator implements Validator {
  @override
  String? validate(String value) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email non valide';
    }
    return null;
  }
}
