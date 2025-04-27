import 'package:firstflutterapp/services/toast_service.dart';
import 'package:firstflutterapp/utils/check-form-data.dart';
import 'package:firstflutterapp/view/register/end-register.dart';
import 'package:firstflutterapp/view/register/register-service.dart';
import 'package:flutter/material.dart';

import '../../components/label-and-input/label-and-input-text.dart';
import '../../services/api_service.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  int step = 1;
  final RegisterService _registerService = RegisterService();
  final CheckFormData _checkFormData = CheckFormData();
  final LabelAndInput _labelAndInput = LabelAndInput();
  final ApiService _apiService = ApiService();
  final ToastService _toastService = ToastService();

  // Step 1 Controllers
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Step 2 Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  DateTime? birthdayDate;
  String? selectedSexe;
  bool isValidEmail = true;
  bool isValidPassword = true;
  bool isValidPseudo = true;
  bool isValidFirstName = true;
  bool isValidLastName = true;
  bool isValidBirthdayDate = true;
  bool isValidSexe = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Bienvenue sur \nOnlyFlick",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      if (step == 2)
                        GestureDetector(
                          onTap: () => setState(() => step = 1),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text("Retour"),
                            ],
                          ),
                        ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            step == 1
                                ? "Informations générales"
                                : "Informations personnelles",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Étape \n ${step}/2",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (step == 1) ..._buildStep1(),
                      if (step == 2) ..._buildStep2(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (step == 1) {
                    final bool formIsValid = _registerService.checkStep1IsOk(
                      emailController.text,
                      passwordController.text,
                      confirmPasswordController.text,
                      pseudoController.text,
                    );

                    if (formIsValid) {
                      setState(() {
                        step = 2;
                        isValidEmail = true;
                        isValidPassword = true;
                        isValidPseudo = true;
                      });
                    } else {
                      setState(() {
                        isValidEmail = _checkFormData.validEmail(
                          emailController.text,
                        );
                        isValidPassword =
                            _registerService.isSamePassword(
                              passwordController.text,
                              confirmPasswordController.text,
                            ) &&
                            _registerService.isValidPassword(
                              passwordController.text,
                            );

                        isValidPseudo = _checkFormData.inputIsNotEmptyOrNull(
                          pseudoController.text,
                        );
                      });
                    }
                  } else {
                    _submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(step == 1 ? "Suivant" : "Créer un compte"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      _labelAndInput.buildLabelAndInputText(
        "Pseudo",
        pseudoController,
        "Entrez votre pseudo",
        obscureText: false,
        hasError: !isValidPseudo,
        messageError: "*Vous devez rentrer un pseudo",
      ),
      _labelAndInput.buildLabelAndInputText(
        "Email",
        emailController,
        "Entrez votre email",
        obscureText: false,
        hasError: !isValidEmail,
        messageError: "*Email invalide",
      ),
      Center(child: Container(width: 200, height: 3, color: Colors.grey)),
      SizedBox(height: 32),
      _labelAndInput.buildLabelAndInputText(
        "Mot de passe",
        passwordController,
        "Entrez votre mot de passe",
        obscureText: true,
        hasError: !isValidPassword,
        messageError: _registerService.getMessageErrorPassword(
          passwordController.text,
          confirmPasswordController.text,
        ),
        helperContent:
            "Le mot de passe doit contenir les caractères suivant: \n - 1 majuscule \n - 1 chiffre \n - Avoir une longueure minimale de 6 caractères",
        helperTitle: "Format de mot de passe",
      ),
      _labelAndInput.buildLabelAndInputText(
        "Retaper le mot de passe",
        confirmPasswordController,
        "Confirmez votre mot de passe",
        obscureText: true,
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      _labelAndInput.buildLabelAndInputText(
        "Prénom",
        firstNameController,
        "Entrez votre prénom",
        obscureText: false,
        hasError: !isValidFirstName,
        messageError: "Le prénom est vide",
      ),
      _labelAndInput.buildLabelAndInputText(
        "Nom de famille",
        lastNameController,
        "Entrez votre nom de famille",
        obscureText: false,
        hasError: !isValidLastName,
        messageError: "Le nom est vide",
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
    ];
  }

  Future<void> _submitForm() async {
    final formIsValid = _registerService.checkStep2IsOk(
      firstNameController.text,
      lastNameController.text,
      birthdayDate,
      selectedSexe,
    );

    if (formIsValid) {
      setState(() {
        isValidSexe = true;
        isValidBirthdayDate = true;
        isValidFirstName = true;
        isValidLastName = true;
        _isLoading = true;
        _errorMessage = '';
      });

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.request(
          method: 'POST',
          endpoint: '/register',
          body: {
            'email': emailController.text,
            'password': passwordController.text,
            "userName": pseudoController.text,
            "firstName": firstNameController.text,
            "lastName": lastNameController.text,
            "birthDayDate": birthdayDate?.toUtc().toIso8601String(),
            "sexe": _registerService.getSexe(selectedSexe),
          },
          withAuth: false,
        );

        if (response.success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EndRegisterView()),
          );
        } else {
          String message =
              response.statusCode == 409 ? "L'email déjà utilisé" : "";
          _toastService.showToast(
            context,
            "Erreur lors de la création \n du compte \n$message",
          );
        }
      } catch (e) {
        _toastService.showToast(
          context,
          "Erreur lors de la création \n du compte",
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        isValidSexe = _checkFormData.inputIsNotEmptyOrNull(selectedSexe);
        isValidBirthdayDate = _checkFormData.dateIsNotEmpty(birthdayDate);
        isValidFirstName = _checkFormData.inputIsNotEmptyOrNull(
          firstNameController.text,
        );
        isValidLastName = _checkFormData.inputIsNotEmptyOrNull(
          lastNameController.text,
        );
      });
    }
  }
}
