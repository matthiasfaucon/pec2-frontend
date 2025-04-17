import 'package:flutter/material.dart';

class CategoriesList extends StatefulWidget {
  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final List<Map<String, String>> categories = [
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chiens", "image": "assets/images/dog.webp"},
    {"label": "Chats", "image": "https://i.imgur.com/wGrhLMg.png"},
    {"label": "Lapins", "image": "https://i.imgur.com/W0kZKWv.png"},
  ];

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final category = categories[index];
          final imagePath = category["image"]!;
          final imageProvider = imagePath.startsWith('http')
              ? NetworkImage(imagePath)
              : AssetImage(imagePath) as ImageProvider;

          return Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: imageProvider,
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

  @override
  Widget build(BuildContext context) {
    return _buildCategoryChips();
  }
}