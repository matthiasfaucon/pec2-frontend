import 'package:firstflutterapp/components/form/custom_form_field.dart';
import 'package:firstflutterapp/config/router.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/services/toast_service.dart';
import 'package:firstflutterapp/services/validators_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../components/form/loading_button.dart' show LoadingButton;

class ConfirmEmailPage extends StatefulWidget {
  const ConfirmEmailPage({super.key});

  @override
  State<ConfirmEmailPage> createState() => _ConfirmEmailPageState();
}

class _ConfirmEmailPageState extends State<ConfirmEmailPage> {
  final _formKeyCode = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ToastService _toastService = ToastService();
  bool _isSubmitted = false;

  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirmation Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKeyCode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _codeController,
                    label: 'Code',
                    validators: [
                      RequiredValidator(),
                      MinimumValidator(() => _codeController.text),
                    ],
                  ),
                  LoadingButton(
                    label: "Valider",
                    isSubmitted: _isSubmitted,
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ),
            // Logique pour confirmer l'email ici
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    String code = _codeController.text;
    if (_formKeyCode.currentState!.validate()) {
      setState(() {
        _isSubmitted = true;
      });
      final response = await _apiService.request(
        method: 'GET',
        endpoint: '/valid-email/$code',
        body: {
          'email': _codeController.text,
        },
        withAuth: false,
      );

      if (response.success) {
        context.go(loginRoute);
      } else {
        _toastService.showToast(
          "Une erreur s'est produite",
          ToastificationType.error,
        );
      }
      setState(() {
        _isSubmitted = false;
      });

    }else{
      _toastService.showToast(
        "Données invalides",
        ToastificationType.error,
      );
    }


  }
}
