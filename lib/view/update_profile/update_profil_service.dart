class UpdateProfileService {
  getSexe(String? selectedSexe) {
    if (selectedSexe != null) {
      switch (selectedSexe) {
        case "WOMAN":
          return "Femme";
        case "MAN":
          return "Homme";
        case "OTHER":
          return "Autre";
      }
    } else {
      return "";
    }
  }
}
