import 'dart:io';
import 'package:firstflutterapp/interfaces/category.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class PostCreationService {
  final ApiService _apiService = ApiService();

  Future<List<Category>> loadCategories() async {
    final response = await _apiService.request(
      method: 'get',
      endpoint: '/categories',
      withAuth: true,
    );

    if (response.success) {
      return (response.data as List)
          .map((item) => Category.fromJson(item))
          .toList();
    }

    throw Exception('Échec du chargement des catégories');
  }

  // Valider les données du post
  String? validatePostData({
    required List<Category> selectedCategories,
    required String name,
    required String description,
  }) {
    if (selectedCategories.isEmpty) {
      return 'Veuillez sélectionner au moins une catégorie';
    }

    if (name.trim().isEmpty) {
      return 'Veuillez ajouter un nom';
    }

    if (description.trim().isEmpty) {
      return 'Veuillez ajouter une description';
    }

    return null;
  }

  // Publier un nouveau post
  Future<void> publishPost({
    required File imageFile,
    required String name,
    required String description,
    required List<Category> selectedCategories,
    required bool isFree,
  }) async {
    try {
      // Extraction des IDs des catégories sélectionnées
      List<String> categoryIds =
          selectedCategories.map((category) => category.id).toList();
      await _apiService.uploadMultipart(
        endpoint: '/posts',
        fields: {
          "name": name.trim(),
          "description": description.trim(),
          "categoryIds": categoryIds.toString(),
          "isFree": isFree.toString(),
        },
        file: imageFile,
        method: 'Post',
        withAuth: true,
      );

    } catch (e) {
      throw Exception('Erreur lors de la publication: $e');
    }
  }

  // Méthode pour initialiser la caméra
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      throw Exception('Erreur lors de l\'initialisation de la caméra: $e');
    }
  }

  File convertXFileToFile(XFile xFile) {
    return File(xFile.path);
  }
}