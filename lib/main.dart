import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firstflutterapp/notifiers/userNotififers.dart';
import 'package:firstflutterapp/notifiers/sse_provider.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:firstflutterapp/config/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file with proper error handling
  try {
    await dotenv.load(fileName: ".env");
    print("Environment file loaded successfully");
  } catch (e) {
    print("Warning: Could not load .env file. Using default values. Error: $e");
    // Set default values if .env file is not available
    dotenv.env['API_BASE_URL_WEB'] = 'https://api.onlyflick.akiagaming.fr';
    dotenv.env['API_BASE_URL_ANDROID'] = 'https://api.onlyflick.akiagaming.fr';
    dotenv.env['API_BASE_URL_DEFAULT'] = 'https://api.onlyflick.akiagaming.fr';
  }
  
  MultiProvider multiProvider = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserNotifier()),
      ChangeNotifierProvider(create: (_) => SSEProvider()),
    ],
    child: const ToastificationWrapper(
      child: MyApp(),
    ),
  );

  runApp(multiProvider);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'OnlyFlick',
          theme: theme,
          darkTheme: darkTheme,
          routerConfig: router,
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fr', 'FR'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}

