import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import '../admin/admin_login_page.dart';
import '../admin/admin_dashboard.dart';
import '../main.dart';

class RouteUtils {
  // Routes de l'application
  static const String homeRoute = '/';
  static const String adminLoginRoute = '/admin-login';
  static const String adminDashboardRoute = '/admin-dashboard';
  static const String mobileHomeRoute = '/mobile-home';
  
  // Définit les routes de l'application
  static Map<String, WidgetBuilder> getAppRoutes() {
    return {
      homeRoute: (context) => _getHomeWidget(),
      adminLoginRoute: (context) => AdminLoginPage(),
      adminDashboardRoute: (context) => AdminDashboardPage(),
      mobileHomeRoute: (context) => const HomePage(),
    };
  }
  
  // Détermine quel widget afficher sur la route home en fonction de la plateforme
  static Widget _getHomeWidget() {
    if (PlatformUtils.isWebPlatform()) {
      return AdminLoginPage();
    } else {
      return const HomePage();
    }
  }
  
  // Redirige vers la route appropriée en fonction de la plateforme
  static void redirectBasedOnPlatform(BuildContext context) {
    if (PlatformUtils.isWebPlatform()) {
      Navigator.of(context).pushReplacementNamed(adminLoginRoute);
    } else {
      // Déjà sur la route mobile, pas besoin de redirection
    }
  }
  
  // Navigation vers le tableau de bord admin
  static void navigateToAdminDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(adminDashboardRoute);
  }
  
  // Navigation vers la page de connexion admin
  static void navigateToAdminLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(adminLoginRoute);
  }
  
  // Navigation vers la page d'accueil mobile
  static void navigateToMobileHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(mobileHomeRoute);
  }
} 