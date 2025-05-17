import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CategoryDelete {
  final BuildContext context;
  final Function onDeleteSuccess;

  CategoryDelete({
    required this.context,
    required this.onDeleteSuccess,
  });

  void showDeleteDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _CategoryDeleteDialog(
        category: category,
        onConfirm: () => _deleteCategory(category),
      ),
    );
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    try {
      final response = await ApiService().request(
        method: 'DELETE',
        endpoint: '/categories/${category['id']}',
        withAuth: true,
      );

      if (response.success) {
        onDeleteSuccess();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catégorie supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${response.error ?? "Une erreur est survenue"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CategoryDeleteDialog extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onConfirm;

  const _CategoryDeleteDialog({
    Key? key,
    required this.category,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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