import 'package:flutter/material.dart';

class ConfirmPopup extends StatelessWidget {
  final String headerMessage;
  final String contentMessage;

  const ConfirmPopup({
    super.key,
    required this.headerMessage,
    required this.contentMessage,
  });

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(headerMessage),
          content: Text(contentMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la popup
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return IconButton(
    //   icon: const Icon(Icons.question_mark_outlined),
    //   onPressed: () {
    //     _showPopup(context); // Appel de la popup dans onPressed
    //   },
    // );
    return IconButton(
      onPressed: () {
        // Action à exécuter lorsque l'icône est pressée
        _showPopup(context);
      },
      icon: Container(
        padding: EdgeInsets.all(2), // Ajuster l'espace autour de l'icône
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Forme circulaire
          border: Border.all(
            color: const Color(0xFF6C3FFE), // Couleur de la bordure (violette)
            width: 1, // Épaisseur de la bordure
          ),
          color: Colors.transparent, // Fond transparent
        ),
        child: Icon(
          Icons.question_mark_outlined, // L'icône de point d'interrogation
          color: const Color(0xFF6C3FFE), // Couleur de l'icône (par exemple, violette)
          size: 12, // Taille de l'icône
        ),
      ),
    );
  }
}
