import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // final url = dotenv.env['API_BASE_URL'] ?? '';
    final url = 'http://10.0.2.2:8080/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Connexion réussie: $data');
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Retourne à la page principale ou rafraîchit
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );

        // Tu peux faire Navigator.push(...) ici si tu veux changer de page
      } else {
        print('Erreur: ${response.statusCode}');
        print('Réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page de Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Connexion",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
