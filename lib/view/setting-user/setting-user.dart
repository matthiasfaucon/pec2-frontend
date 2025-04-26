import 'package:firstflutterapp/theme.dart';
import 'package:firstflutterapp/view/update_password_view.dart';
import 'package:flutter/material.dart';

import '../../utils/auth_utils.dart' show AuthUtils;
import '../../utils/route_utils.dart';

class SettingUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paramètres")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdatePasswordView()),
                );
              },
              style: AppTheme.emptyButtonStyle.merge(ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 50)
              )) ,
              child: const Text(
                "Changer le mot de passe",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => UpdatePasswordView()),
                // );
              },
              style: AppTheme.emptyButtonStyle.merge(ElevatedButton.styleFrom(
                fixedSize: const Size(300, 50)
              )) ,
              child: const Text(
                "Demande/Support",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                  await AuthUtils.logout();
                  if (context.mounted) {
                    RouteUtils.navigateToMobileHome(context);
                  }
              },
              style: AppTheme.filledButtonStyle.merge(ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 50)
              )) ,
              child: const Text(
                "Deconnexion",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
