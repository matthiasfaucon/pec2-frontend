import 'package:flutter/material.dart';

class CategoryDeleteDialog extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onConfirm;

  const CategoryDeleteDialog({
    Key? key,
    required this.category,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupérer le nombre de posts de manière sécurisée
    final posts = category['posts'] as List?;
    final postsCount = posts?.length ?? 0;

    return AlertDialog(
      title: const Text(
        "Supprimer la catégorie",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Êtes-vous sûr de vouloir supprimer la catégorie '${category['name']}' ?",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (postsCount > 0)
            Text(
              "Cette catégorie contient $postsCount article${postsCount > 1 ? 's' : ''}. La suppression retirera la catégorie de tous ces articles.",
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text("Supprimer"),
        ),
      ],
    );
  }
} 