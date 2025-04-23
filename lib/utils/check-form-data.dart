class CheckFormData{
  bool validEmail(String inputEmail) {
    final String email = inputEmail.trim();
    final RegExp emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    bool isValid = true;

    if (!emailRegex.hasMatch(email)) {
      isValid = false;
    }

    return isValid;
  }
}