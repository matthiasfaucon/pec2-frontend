import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../services/api_service.dart';

class CategoryUpdate {
  final BuildContext context;
  final Function onUpdateSuccess;

  CategoryUpdate({
    required this.context,
    required this.onUpdateSuccess,
  });

  void showUpdateDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _CategoryUpdateDialog(
        category: category,
        onUpdate: (name, imageBytes, mimeType) => 
          _updateCategory(category['id'], name, imageBytes, mimeType),
      ),
    );
  }

  Future<void> _updateCategory(
    String categoryId,
    String name,
    Uint8List? imageBytes,
    String? mimeType,
  ) async {
    try {
      final fields = {'name': name};
      Object? file;

      if (imageBytes != null && mimeType != null) {
        file = http.MultipartFile.fromBytes(
          'picture',
          imageBytes,
          filename: 'category.$mimeType',
          contentType: MediaType('image', mimeType),
        );
      }

      final response = await ApiService().uploadMultipart(
        endpoint: '/categories/$categoryId',
        method: 'PUT',
        fields: fields,
        file: file ?? http.MultipartFile.fromBytes('picture', [], filename: 'empty'),
        withAuth: true,
      );

      if (response.success) {
        onUpdateSuccess();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catégorie mise à jour avec succès'),
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
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CategoryUpdateDialog extends StatefulWidget {
  final Map<String, dynamic> category;
  final Function(String name, Uint8List? imageBytes, String? mimeType) onUpdate;

  const _CategoryUpdateDialog({
    Key? key,
    required this.category,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CategoryUpdateDialogState createState() => _CategoryUpdateDialogState();
}

class _CategoryUpdateDialogState extends State<_CategoryUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  Uint8List? _selectedImageBytes;
  String? _selectedImageMimeType;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category['name']);
    _currentImageUrl = widget.category['pictureUrl'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedImageBytes = result.files.first.bytes;
        _selectedImageMimeType = result.files.first.name.split('.').last;
        _imageError = false;
      });
    }
  }

  bool _validateForm() {
    setState(() {
      _imageError = _selectedImageBytes == null && _currentImageUrl == null;
    });

    return _formKey.currentState!.validate() && !_imageError;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Modifier la catégorie",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom de la catégorie est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Image de la catégorie',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _imageError ? Colors.red : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _selectedImageBytes!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _currentImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _currentImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade400,
                              ),
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: _imageError ? Colors.red : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Cliquez pour ajouter une image",
                            style: TextStyle(
                              color: _imageError ? Colors.red : Colors.grey.shade600,
                            ),
                          ),
                          if (_imageError) ...[
                            const SizedBox(height: 8),
                            Text(
                              "L'image est requise",
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Choisir une nouvelle image'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_validateForm()) {
                    setState(() => _isLoading = true);
                    widget.onUpdate(
                      _nameController.text.trim(),
                      _selectedImageBytes,
                      _selectedImageMimeType,
                    );
                    Navigator.of(context).pop();
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
} 