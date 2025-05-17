import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../../services/api_service.dart';

class CategoryCreateDialog extends StatefulWidget {
  final Function onCategoryCreated;

  const CategoryCreateDialog({
    Key? key,
    required this.onCategoryCreated,
  }) : super(key: key);

  @override
  _CategoryCreateDialogState createState() => _CategoryCreateDialogState();
}

class _CategoryCreateDialogState extends State<CategoryCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _imagePreviewUrl;
  bool _isLoading = false;
  String? _errorMessage;
  bool _imageError = false;

  Future<void> _pickImage() async {
    try {
      final FilePickerResult? resultPicker = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (resultPicker != null && resultPicker.files.isNotEmpty) {
        final PlatformFile pickedFile = resultPicker.files.single;
        final Uint8List fileBytes = pickedFile.bytes!;
        final base64Image = base64Encode(fileBytes);
        
        setState(() {
          _imagePreviewUrl = "data:image/${pickedFile.extension};base64,$base64Image";
          _imageError = false; // Réinitialiser l'erreur quand une image est sélectionnée
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la sélection de l'image: $e";
      });
    }
  }

  Future<void> _createCategory() async {
    setState(() {
      _imageError = _imagePreviewUrl == null;
    });

    if (!_formKey.currentState!.validate() || _imageError) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final imageData = _imagePreviewUrl!.split(',')[1];
      final imageBytes = base64Decode(imageData);
      final headerSplit = _imagePreviewUrl!.split(',');
      final mime = headerSplit[0].split(':')[1].split(';')[0];
      final ext = mime.split('/')[1];
      
      final mimeType = lookupMimeType('', headerBytes: imageBytes);
      final mediaType = mimeType != null 
          ? MediaType.parse(mimeType)
          : MediaType('application', 'octet-stream');

      final multipartFile = http.MultipartFile.fromBytes(
        'picture',
        imageBytes,
        filename: 'category.$ext',
        contentType: mediaType,
      );

      final response = await ApiService().uploadMultipart(
        endpoint: '/categories',
        method: 'POST',
        fields: {
          'name': _nameController.text.trim(),
        },
        file: multipartFile,
        withAuth: true,
      );

      if (response.success) {
        widget.onCategoryCreated();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _errorMessage = response.error ?? "Une erreur est survenue";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la création: $e";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nouvelle catégorie",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nom de la catégorie",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Le nom est requis";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Image de la catégorie",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _imageError ? Colors.red : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imagePreviewUrl != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imagePreviewUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    onPressed: _pickImage,
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
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
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createCategory,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Créer la catégorie"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 