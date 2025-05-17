import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/admin/category_create_dialog.dart';
import '../components/admin/category_delete.dart';
import '../components/admin/category_update.dart';

class CategoriesManagement extends StatefulWidget {
  const CategoriesManagement({Key? key}) : super(key: key);

  @override
  _CategoriesManagementState createState() => _CategoriesManagementState();
}

class _CategoriesManagementState extends State<CategoriesManagement> {
  List<dynamic> _categories = [];
  bool _loadingCategories = false;
  late CategoryDelete _deleteHandler;
  late CategoryUpdate _updateHandler;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deleteHandler = CategoryDelete(
      context: context,
      onDeleteSuccess: () {
        setState(() {
          _fetchCategories();
        });
      },
    );
    _updateHandler = CategoryUpdate(
      context: context,
      onUpdateSuccess: () {
        setState(() {
          _fetchCategories();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gestion des catégories",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CategoryCreateDialog(
                        onCategoryCreated: () {
                          _fetchCategories();
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Nouvelle catégorie"),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _loadingCategories
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Aucune catégorie trouvée",
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchCategories,
                              child: const Text("Actualiser"),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: category['pictureUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.network(
                                        category['pictureUrl'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return CircleAvatar(
                                            backgroundColor: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported),
                                          );
                                        },
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey.shade200,
                                      child: const Icon(Icons.category),
                                    ),
                              title: Text(
                                category['name'] ?? 'Sans nom',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () {
                                      _updateHandler.showUpdateDialog(category);
                                    },
                                    tooltip: 'Modifier',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      _deleteHandler.showDeleteDialog(category);
                                    },
                                    tooltip: 'Supprimer',
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('ID', category['id'] ?? 'N/A'),
                                      _buildDetailRow('Nom', category['name'] ?? 'N/A'),
                                      if (category['pictureUrl'] != null)
                                        _buildDetailRow(
                                          'Image',
                                          category['pictureUrl'],
                                          isImage: true,
                                        ),
                                      _buildDetailRow(
                                        'Créé le',
                                        DateFormatter.formatDateTime(category['createdAt']),
                                      ),
                                      _buildDetailRow(
                                        'Mis à jour le',
                                        DateFormatter.formatDateTime(category['updatedAt']),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isImage = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isImage && value != 'N/A'
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(value);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.fullscreen),
                        label: const Text('Voir en plein écran'),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                value,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.red.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Erreur de chargement de l\'image',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final url = Uri.parse(value);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _loadingCategories = true;
    });

    try {
      final response = await ApiService().request(
        method: 'GET',
        endpoint: '/categories',
        withAuth: true,
      );

      if (response.data is List) {
        setState(() {
          _categories = response.data;
          _loadingCategories = false;
        });
      } else {
        developer.log('Réponse reçue mais pas au format attendu: $response');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Format de réponse inattendu de l'API"),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _categories = [];
          _loadingCategories = false;
        });
      }
    } catch (error) {
      developer.log('Erreur lors de la récupération des catégories: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: $error"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _categories = [];
        _loadingCategories = false;
      });
    }
  }
}
