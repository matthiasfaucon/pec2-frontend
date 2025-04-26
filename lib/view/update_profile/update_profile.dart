import 'package:firstflutterapp/interfaces/user.dart';
import 'package:firstflutterapp/view/update_profile/update_profil_service.dart';
import 'package:flutter/material.dart';

import '../../components/label-and-input/label-and-input-text.dart';

class UpdateProfile extends StatefulWidget {
  final User user;

  // Constructeur
  UpdateProfile({required this.user, super.key});

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  // Déclaration des TextEditingController
  late TextEditingController pseudoController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController bioController;
  final LabelAndInput _labelAndInput = LabelAndInput();
  final UpdateProfileService _updateProfileService = UpdateProfileService();
  DateTime? birthdayDate;
  String? selectedSexe;
  bool isValidEmail = true;
  bool isValidPassword = true;
  bool isValidPseudo = true;
  bool isValidFirstName = true;
  bool isValidLastName = true;
  bool isValidBirthdayDate = true;
  bool isValidSexe = true;

  @override
  void initState() {
    super.initState();

    // Initialisation des controllers avec les valeurs du User
    pseudoController = TextEditingController(text: widget.user.userName);
    emailController = TextEditingController(text: widget.user.email);
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    bioController = TextEditingController(text: widget.user.bio ?? "");
    setState(() {
      birthdayDate = widget.user.birthDayDate;
      selectedSexe = _updateProfileService.getSexe(widget.user.sexe);
    });
  }

  @override
  void dispose() {
    // Libérer les controllers
    pseudoController.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modification profil")),
      body: SingleChildScrollView( // Ajout de la ScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelAndInput.buildLabelAndInputText(
              "Pseudo",
              pseudoController,
              "Entrez votre pseudo",
              obscureText: false,
              hasError: !isValidPseudo,
              messageError: "*Vous devez rentrer un pseudo",
            ),
            _labelAndInput.buildLabelAndInputText(
              "Nom de famille",
              lastNameController,
              "Entrez votre nom de famille",
              obscureText: false,
              hasError: !isValidLastName,
              messageError: "Le prénom est vide",
            ),
            _labelAndInput.buildLabelAndInputText(
              "Prénom",
              firstNameController,
              "Entrez votre prénom",
              obscureText: false,
              hasError: !isValidFirstName,
              messageError: "Le prénom est vide",
            ),
            _labelAndInput.buildLabelAndInputText(
              "Bio",
              bioController,
              "Entrez votre bio",
              obscureText: false,
              maxLine: 5
            ),
            _labelAndInput.buildLabelAndCalendar(
              "Date d'anniversaire",
              !isValidBirthdayDate,
              "La date doit être renseignée",
              context,
              setState,
              birthdayDate,
                  (newDate) => setState(() => birthdayDate = newDate),
            ),
            _labelAndInput.buildLabelAndRadioList(
              "Sexe",
              !isValidSexe,
              "Cochez une option",
              ["Homme", "Femme", "Autre"],
              selectedSexe,
                  (option) => setState(() => selectedSexe = option),
            ),
            ElevatedButton(
              onPressed: () {
                // Ici, tu peux récupérer les nouvelles valeurs du formulaire
                print('Pseudo: ${pseudoController.text}');
                print('Email: ${emailController.text}');
                print('Prénom: ${firstNameController.text}');
                print('Nom: ${lastNameController.text}');
                print('Bio: ${bioController.text}');
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)) ,
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}

