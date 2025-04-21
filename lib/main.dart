import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:firstflutterapp/components/free-feed/container.dart';
import 'package:firstflutterapp/components/header/container.dart';
import 'package:firstflutterapp/components/search-bar/search-bar.dart';
import 'package:firstflutterapp/components/bottom-navigation/container.dart';
import 'package:firstflutterapp/components/categories/categories-list.dart';
import 'package:firstflutterapp/page/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/page/profil_page.dart';
import 'package:firstflutterapp/utils/platform_utils.dart';
import 'package:firstflutterapp/utils/route_utils.dart';
import 'package:firstflutterapp/utils/auth_utils.dart';
import 'dart:developer' as developer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Affiche des informations sur la plateforme pour le débogage
  PlatformUtils.logPlatformInfo();
  
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
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool isConnected = false;
  bool isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    
    // Redirection en fonction de la plateforme
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
      developer.log('Erreur lors de la vérification du statut de connexion: $e');
      setState(() {
        isConnected = false;
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthUtils.logout();
    setState(() {
      isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si nous sommes sur le web, ne pas afficher l'interface mobile
    if (PlatformUtils.isWebPlatform()) {
      return const Scaffold(
        body: Center(
          child: Text("Cette application n'est pas disponible sur le web. Veuillez utiliser un appareil mobile."),
        ),
      );
    }
    
    final bottomNavigationItems = ContainerBottomNavigation().buildItems(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!isConnected) {
      return LoginPage();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Pet Shop"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Déconnexion",
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: bottomNavigationItems,
      ),
      body: _getPageForIndex(selectedIndex),
    );
  }
  
  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0: 
        return _buildHomePage();
      case 1:
        return Center(child: Text("Page Favorites en construction"));
      case 2: 
        return Center(child: Text("Page Catalogue en construction"));
      case 3: 
        return const ProfilePage();
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
