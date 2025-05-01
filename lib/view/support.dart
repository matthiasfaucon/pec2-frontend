import 'package:flutter/material.dart';
import '../components/label-and-input/label-and-input-text.dart';
import '../services/api_service.dart';
  


class SupportPage extends StatelessWidget {
  final LabelAndInput _labelAndInput = LabelAndInput();
  final ApiService _apiService = ApiService();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _objetController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
            _labelAndInput.buildLabelAndInputText('Prénom', _prenomController, 'Entrez votre prénom'),
          _labelAndInput.buildLabelAndInputText('Nom', _nomController, 'Entrez votre nom'),
          _labelAndInput.buildLabelAndInputText('Email', _emailController, 'Entrez votre email'),
          _labelAndInput.buildLabelAndInputText('Objet', _objetController, 'Entrez l\'objet de votre message'),
          _labelAndInput.buildLabelAndInputText('Message', _messageController, 'Entrez votre message', maxLine: 5),                 
          ElevatedButton(
            onPressed: () {
              // _apiService.sendSupportMessage(context);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50)
            ) ,
            child: Text('Envoyer'),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

