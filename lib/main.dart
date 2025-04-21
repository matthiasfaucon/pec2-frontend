import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firstflutterapp/components/free-feed/container.dart';
import 'package:firstflutterapp/components/header/container.dart';
import 'package:firstflutterapp/components/search-bar/search-bar.dart';
import 'package:firstflutterapp/components/bottom-navigation/container.dart';
import 'package:firstflutterapp/components/categories/categories-list.dart';
import 'package:firstflutterapp/page/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:firstflutterapp/page/profil_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firstflutterapp/admin/admin_login_page.dart';
import 'package:firstflutterapp/admin/admin_dashboard.dart';
import 'package:firstflutterapp/utils/auth_utils.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Configurer l'URL de l'API en fonction de la plateforme
  String apiBaseUrl;
  if (kIsWeb) {
    apiBaseUrl = dotenv.env['API_BASE_URL_WEB'] ?? 'http://localhost:8080';
  } else if (Platform.isAndroid) {
    apiBaseUrl = dotenv.env['API_BASE_URL_ANDROID'] ?? 'http://10.0.2.2:8080';
  } else {
    apiBaseUrl = dotenv.env['API_BASE_URL_DEFAULT'] ?? 'http://localhost:8080';
  }
  
  runApp(MyApp(apiBaseUrl: apiBaseUrl));
}

class MyApp extends StatelessWidget {
  final String apiBaseUrl;
  
  const MyApp({super.key, required this.apiBaseUrl});

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
        routes: {
          '/': (context) => kIsWeb ? AdminLoginPage() : const HomePage(),
          '/admin-login': (context) => AdminLoginPage(),
          '/admin-dashboard': (context) => AdminDashboardPage(),
          '/mobile-home': (context) => const HomePage(),
        },
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
    
    // Si nous sommes sur le web, redirigez vers l'interface admin
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/admin-login');
      });
      return;
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    setState(() {
      isConnected = token != null;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    setState(() {
      isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si nous sommes sur le web, ne pas afficher l'interface mobile
    if (kIsWeb) {
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
          // Nous supprimons le bouton Admin car il n'est pas pertinent sur mobile
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
