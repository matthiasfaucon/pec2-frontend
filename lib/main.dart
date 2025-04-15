import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firstflutterapp/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PetApp());
}

class PetApp extends StatelessWidget {
  const PetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.lightTheme,
      dark: AppTheme.darkTheme,
      initial: AdaptiveThemeMode.system,
      builder:
          (theme, darkTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pet Shop',
            theme: theme,
            darkTheme: darkTheme,
            home: const HomePage(),
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

  final List<Map<String, String>> categories = [
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chats", "image": "https://i.imgur.com/wGrhLMg.png"},
    {"label": "Lapins", "image": "https://i.imgur.com/W0kZKWv.png"},
  ];

  final List<Map<String, String>> pets = [
    {
      "name": "Puppy Max",
      "location": "New-York, USA",
      "price": "\$200",
      "image": "https://i.imgur.com/30wOxPJ.jpeg",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
    {
      "name": "Cat Chip",
      "location": "New-York, USA",
      "price": "\$180",
      "image": "https://i.imgur.com/hZ1TnYm.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
            activeIcon: Icon(Icons.home_filled),
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
            activeIcon: Icon(Icons.favorite_rounded),
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Catalog',
            activeIcon: Icon(Icons.list_alt_rounded),
            backgroundColor:
                Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategoryChips(),
              const SizedBox(height: 32),
              _buildForYouSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Salut,", style: TextStyle(fontSize: 16)),
            Text(
              "Matthias Faucon",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: Theme.of(context).brightness == Brightness.light
            ? const Icon(Icons.dark_mode)
            : const Icon(Icons.light_mode),
          onPressed: () {
            if (Theme.of(context).brightness == Brightness.light) {
              AdaptiveTheme.of(context).setDark();
            } else {
              AdaptiveTheme.of(context).setLight();
            }
          },
        ),

        const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage("https://i.imgur.com/QCNbOAo.png"),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Rechercher quelque chose...',
        prefixIcon: const Icon(Icons.search),
        // suffixIcon: const Icon(Icons.filter_alt_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final category = categories[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(category["image"]!),
              ),
              const SizedBox(height: 8),
              Text(
                category["label"]!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForYouSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Pour vous",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Voir tout",
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.6,
          ),
          itemCount: pets.length,
          itemBuilder: (_, index) {
            final pet = pets[index];
            return _buildPetCard(pet);
          },
        ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, String> pet) {
    return Container(
      width: 160,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  pet["image"]!,
                  height: 184,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  child: Icon(
                    Icons.favorite_border,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pet["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pet["location"]!,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pet["price"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
