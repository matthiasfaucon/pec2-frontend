import 'dart:convert';

import 'package:firstflutterapp/view/creator/creator-service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../../components/label-and-input/label-and-input-text.dart';
import '../../services/api_service.dart';
import '../../utils/check-form-data.dart';

class CreatorView extends StatefulWidget {
  @override
  _CreatorViewState createState() => _CreatorViewState();
}

class _CreatorViewState extends State<CreatorView> {
  final CheckFormData _checkFormData = CheckFormData();
  final LabelAndInput _labelAndInput = LabelAndInput();
  final CreatorService _creatorService = CreatorService();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController siretController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  bool _isLoading = false;
  int step = 1;
  String selectedFile = "";
  String selectedFileName = "";
  bool isValidCountry = true;
  String? selectedCountry = "France";
  List<String> countries = [];

  @override
  void initState() {
    super.initState();
    loadCountriesFromService();
  }

  void loadCountriesFromService() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _creatorService.loadCountries();
    setState(() {
      countries = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demande créateur")),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C3FFE)),
              )
              : _buildCreatorContent(),
    );
  }

  Widget _buildCreatorContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (step == 1) ..._buildStep1(),
          if (step == 2) ..._buildStep2(),
          ElevatedButton(
            onPressed: () {
              if (step == 1) {
                setState(() {
                  step = 2;
                });
              } else {
                _submitForm();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(step == 1 ? "Suivant" : "Valider"),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      _labelAndInput.buildLabelAndInputText(
        'Siret',
        siretController,
        'Numéro de siret',
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      _labelAndInput.buildLabelAndInputText(
        'Nom de la société',
        companyNameController,
        'Entrez le nom de la société',
      ),
      _labelAndInput.buildLabelAndInputText(
        'Adresse',
        addressController,
        'Entrez l\'adresse de la société',
      ),
      _labelAndInput.buildLabelAndInputText(
        'Ville',
        cityController,
        'Entrez la ville de la société',
      ),
      _labelAndInput.buildLabelAndInputText(
        'Code postal',
        zipCodeController,
        'Entrez le code postal de la société',
      ),
      _labelAndInput.buildLabelAndSearchList(
        'Ville',
        !isValidCountry,
        "lala",
        countries,
        (option) => setState(() => selectedCountry = option),
      ),

      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Kbis"),
                content: const Text(""),
                actions: <Widget>[
                  TextButton(
                    child: const Text("Télécharger le KBIS"),
                    onPressed: () async {
                      Navigator.of(context).pop(); // On ferme le Dialog avant

                      final XFile? pickedFile = await _picker.pickMedia();

                      if (pickedFile != null) {
                        setState(() {
                          selectedFile = pickedFile.path;
                          final String fileName =
                              pickedFile.path.split('/').last;
                          selectedFileName =
                              fileName.length > 30
                                  ? fileName.substring(0, 30)
                                  : fileName;
                        });
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24),
            _labelAndInput.buildLabel('Kbis'),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.file_present, size: 40, color: Colors.blue),
                  onPressed: () async {
                    final XFile? pickedFile = await _picker.pickMedia();

                    if (pickedFile != null) {
                      setState(() {
                        selectedFile = pickedFile.path;
                        final String fileName = pickedFile.path.split('/').last;
                        selectedFileName =
                            fileName.length > 30
                                ? fileName.substring(0, 30)
                                : fileName;
                      });
                    }
                  },
                ),
                Text(selectedFileName),
              ],
            ),
            SizedBox(height: 24)
          ],
        ),
      ),
    ];
  }

  Future<void> _submitForm() async {
    late final ApiResponse response;

    String? mimeType = lookupMimeType(selectedFile);
    var file = await http.MultipartFile.fromPath(
      'file',
      selectedFile,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );

    response = await _apiService.uploadMultipart(
      endpoint: '/content-creators',
      fields: {
        "siretNumber": siretController.text,
        "companyName": companyNameController.text,
        "streetAddress": addressController.text,
        "postalCode": zipCodeController.text,
        "city": cityController.text,
        "country": selectedCountry as String,
        "companyType": "Micro",
        "iban": "FR7630006000011234567890189",
        "bic": "BNPAFRPP",
        "vatNumber": "FR12345678901",
      },
      file: file,
      method: 'post',
    );
  }
}
