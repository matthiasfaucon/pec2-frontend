import 'package:flutter/material.dart';

class ContainerBottomNavigation extends StatelessWidget {
  const ContainerBottomNavigation({super.key});

  List<BottomNavigationBarItem> buildItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home),
        label: 'Accueil',
        activeIcon: const Icon(Icons.home_filled),
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.favorite),
        label: 'Favorites',
        activeIcon: const Icon(Icons.favorite_rounded),
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.list),
        label: 'Catalog',
        activeIcon: const Icon(Icons.list_alt_rounded),
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
      // BottomNavigationBarItem(
      //   icon: GestureDetector(
      //     onTap: () {
      //       // Naviguer vers la page de profil
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => ProfilePage()),  // Remplace ProfilePage() par ta page de profil
      //       );
      //     },
      //     child: const CircleAvatar(
      //       radius: 30,
      //       backgroundImage: NetworkImage("https://i.imgur.com/QCNbOAo.png"),
      //     ),
      //   ),
      //   label: '',
      //   backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Juste un placeholder, à adapter selon le besoin
    return const SizedBox.shrink();
  }
}