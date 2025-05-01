import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../components/label-and-input/label-and-input-text.dart';
import '../services/api_service.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final LabelAndInput _labelAndInput = LabelAndInput();
  final ApiService _apiService = ApiService();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _objetController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _sendSupportMessage() async {
    if (_prenomController.text.isEmpty ||
        _nomController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _objetController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.request(
        method: 'POST',
        endpoint: '/contact',
        withAuth: false,
        body: {
          'firstName': _prenomController.text,
          'lastName': _nomController.text,
          'email': _emailController.text,
          'subject': _objetController.text,
          'message': _messageController.text,
        },
      );

      if (response.success) {
        _prenomController.clear();
        _nomController.clear();
        _emailController.clear();
        _objetController.clear();
        _messageController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message envoyé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${response.error ?? "Une erreur est survenue"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      developer.log('Erreur envoi message support: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
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
              const SizedBox(height: 20),
              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _sendSupportMessage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50)
                    ),
                    child: const Text('Envoyer'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _objetController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

