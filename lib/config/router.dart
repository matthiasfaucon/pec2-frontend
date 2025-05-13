import 'package:firstflutterapp/admin/admin_dashboard.dart';
import 'package:firstflutterapp/notifiers/userNotififers.dart';
import 'package:firstflutterapp/screens/home_view.dart';
import 'package:firstflutterapp/screens/post-creation/upload-photo.dart';
import 'package:firstflutterapp/screens/profile/profil_view.dart';
import 'package:firstflutterapp/screens/profile/setting-user/setting-user.dart';
import 'package:firstflutterapp/screens/profile/update_profile/update_profile.dart';
import 'package:firstflutterapp/screens/register/register_view.dart';
import 'package:firstflutterapp/screens/sub_feed_view/sub_feed_view.dart';
import 'package:firstflutterapp/screens/support.dart';
import 'package:firstflutterapp/screens/update_password_view.dart';
import 'package:firstflutterapp/screens/search_view/search_view.dart';
import 'package:firstflutterapp/components/bottom-navigation/container.dart';
import 'package:go_router/go_router.dart';
import 'package:firstflutterapp/screens/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const homeRoute = '/';
const loginRoute = '/login';
const uploadPhotoRoute = '/upload-photo';
const subFeedRoute = '/sub';
const registerRoute = '/register';
const profileRoute = '/profile';
const editProfileRoute = '/profile/edit';
const profileParams = '/profile/params';
const profileUpdatePassword = '/profile/params/update-password';
const profileSupport = '/profile/params/support';
const adminRoute = '/admin';
const adminDashboard = '/admin/dashboard';
const searchRoute = '/search';

Future<String?> hasAdminPermissions(
  BuildContext context,
  GoRouterState state,
) async {
  final user = context.read<UserNotifier>();

  if (await user.isAdmin()) {
    return null;
  }

  return loginRoute;
}

Future<String?> isAuthenticated(
  BuildContext context,
  GoRouterState state,
) async {
  final session = context.read<UserNotifier>();

  if (await session.isAuthenticated()) {
    return null;
  }

  return loginRoute;
}

final router = GoRouter(
  initialLocation: homeRoute,
  routes: [
    /// Routes avec BottomNavigationBar
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.toString();
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavBar(currentPath: location),
        );
      },
      routes: [
        GoRoute(
          path: homeRoute,
          builder: (context, state) => HomeView(),
          redirect: (context, state) {
            return isAuthenticated(context, state);
          },
        ),
        GoRoute(
          path: searchRoute,
          builder: (context, state) => SearchView(),
          redirect: (context, state) {
            return isAuthenticated(context, state);
          },
        ),
        GoRoute(
          path: uploadPhotoRoute,
          builder: (context, state) => UploadPhotoView(),
          redirect: (context, state) {
            return isAuthenticated(context, state);
          },
        ),
        GoRoute(
          path: subFeedRoute,
          builder: (context, state) => SubFeedView(),
          redirect: (context, state) {
            return isAuthenticated(context, state);
          },
        ),
        GoRoute(
          path: profileRoute,
          builder: (context, state) => ProfileView(),
          redirect: (context, state) {
            return isAuthenticated(context, state);
          },
          routes: [
            GoRoute(path: 'edit', builder: (context, state) => UpdateProfile()),
            GoRoute(
              path: 'params',
              builder: (context, state) => SettingUser(),
              routes: [
                GoRoute(
                  path: 'update-password',
                  builder: (context, state) => UpdatePasswordView(),
                ),
                GoRoute(
                  path: 'support',
                  builder: (context, state) => SupportPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    /// Autres routes (sans menu)
    GoRoute(path: loginRoute, builder: (context, state) => LoginView()),
    GoRoute(path: registerRoute, builder: (context, state) => RegisterView()),
    GoRoute(
      path: adminRoute,
      builder: (context, state) => AdminDashboardPage(),
      redirect: (context, state) async {
        String? userIsConnected = await isAuthenticated(context, state);
        String? hasAdminRole = await hasAdminPermissions(context, state);

        if (userIsConnected != null || hasAdminRole != null) {
          return loginRoute;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) => AdminDashboardPage(),
        ),
      ],
    ),
  ],
  refreshListenable: UserNotifier(),
);
