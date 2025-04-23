import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

import '../../view/login_view.dart';


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
              "Test",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon:
          Theme.of(context).brightness == Brightness.light
              ? const Icon(Icons.dark_mode)
              : const Icon(Icons.light_mode),
          onPressed: () {
            if (Theme.of(context).brightness == Brightness.light) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginView(),
              )
            );
          },
          child: const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage("https://i.imgur.com/QCNbOAo.png"),
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return _buildHeader();
  }
}