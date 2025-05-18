import 'package:firstflutterapp/components/form/loading_button.dart';
import 'package:firstflutterapp/config/router.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EndRegisterView extends StatelessWidget {
  const EndRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double formWidth =
                constraints.maxWidth > 800
                    ? constraints.maxWidth / 3
                    : double.infinity;

            return Center(
              child: Container(
                width: formWidth,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                      'assets/images/sendEmail.png',
                      width: 300,
                      height: 300,
                    ),
                    SizedBox(height: 32),
                    Text(
                      "Vous devez confirmer votre email avant de pouvoir vous connecter.\n \n Si vous ne le trouvez pas, regardez dans vos spams.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: LoadingButton(
                        onPressed: () {
                          context.go(confirmEmailRoute);
                        },
                        label: 'Confirmer mon email',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
