import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firstflutterapp/components/bottom-navigation/container.dart';
import 'package:firstflutterapp/components/categories/categories-list.dart';
import 'package:firstflutterapp/components/free-feed/container.dart';
import 'package:firstflutterapp/components/header/container.dart';
import 'package:firstflutterapp/components/search-bar/search-bar.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:firstflutterapp/utils/auth_utils.dart';
import 'package:firstflutterapp/utils/platform_utils.dart';
import 'package:firstflutterapp/utils/route_utils.dart';
import 'package:firstflutterapp/view/login_view.dart';
import 'package:firstflutterapp/view/post-creation/upload-photo.dart';
import 'package:firstflutterapp/view/profil_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: AdaptiveThemeMode.system,
      builder:
          (theme, darkTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'OnlyFlick',
            theme: theme,
            darkTheme: darkTheme,
            initialRoute: '/',
            routes: RouteUtils.getAppRoutes(),
            locale: Locale('fr', 'FR'),
            // Langue française
            supportedLocales: [
              Locale('en', 'US'), // Langue anglaise
              Locale('fr', 'FR'), // Langue française
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
    );
  }
}

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool isConnected = false;
  bool isLoading = true;
  final ApiService _apiService = ApiService();
  // final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    selectedIndex = widget.initialIndex;
    // _deepLinkService.listenDeepLinks(context);
    if (PlatformUtils.isWebPlatform()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouteUtils.navigateToAdminLogin(context);
      });
      return;
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      final bool loggedIn = await AuthUtils.isLoggedIn();

      setState(() {
        isConnected = loggedIn;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isWebPlatform()) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Cette application n'est pas disponible sur le web. Veuillez utiliser un appareil mobile.",
          ),
        ),
      );
    }

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isConnected) {
      return LoginView();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: ContainerBottomNavigation(
        selectedIndex: selectedIndex,
        onItemSelected: (index) => setState(() => selectedIndex = index),
      ),
      body: _getPageForIndex(selectedIndex),
    );
  }

  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomePage();
      case 1:
        return Center(child: Text("Page Recherche en construction"));
      case 2:
        return const UploadPhotoView();
      case 3:
        return Center(child: Text("Page Tendances en construction"));
      case 4:
        return const ProfileView();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Header(),
            SizedBox(height: 24),
            SearchBarOnlyFlic(),
            SizedBox(height: 24),
            CategoriesList(),
            SizedBox(height: 32),
            FreeFeed(),
          ],
        ),
      ),
    );
  }
}
