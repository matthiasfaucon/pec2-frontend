import 'package:firstflutterapp/theme.dart';
import 'package:firstflutterapp/screens/login_view.dart';
import 'package:flutter/material.dart';

class EndRegisterView extends StatefulWidget {
  @override
  _EndRegisterViewState createState() => _EndRegisterViewState();
}

class _EndRegisterViewState extends State<EndRegisterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Merci de vous être inscrit à",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  " OnlyFlick",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Image.asset(
              'assets/images/fin-register.png',
              width: 400,
              height: 400,
            ),
            SizedBox(height: 32),
            Text(
              "Vous devez confirmer votre email avant de pouvoir vous connecter.\n \n Si vous ne le trouvez pas, regardez dans vos spams.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginView()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF6C3FFE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
