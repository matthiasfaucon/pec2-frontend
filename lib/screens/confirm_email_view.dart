import 'package:flutter/material.dart';

class ConfirmEmailPage extends StatelessWidget {
  final String token;

  ConfirmEmailPage({required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirmation Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Confirmer l'email avec le token : $token"),
            // Logique pour confirmer l'email ici
          ],
        ),
      ),
    );
  }
}