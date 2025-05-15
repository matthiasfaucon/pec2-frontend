import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Salut,", style: TextStyle(fontSize: 16)),
            Text(
              "John Doe",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Action pour les notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: () {
                // Action pour envoyer un message
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildHeader();
  }
}
