import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../components/categories/categories-list.dart';
import '../components/free-feed/container.dart';
import '../components/header/container.dart';
import '../components/search-bar/search-bar.dart';
import '../config/router.dart';
import '../notifiers/userNotififers.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final userNotifier = context.watch<UserNotifier>();
    //
    // // WidgetsBinding.instance.addPostFrameCallback((_) {
    // if (userNotifier.user == null) {
    //   context.go(loginRoute);
    // } else if (userNotifier.user!.role == 'ADMIN') {
    //   context.go(adminRoute);
    // }
    // // });

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
