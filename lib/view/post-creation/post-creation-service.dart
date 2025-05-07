import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firstflutterapp/interfaces/category.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class PostCreationService {
  
  final ApiService _apiService = ApiService();
  
  // Récupérer les catégories depuis l'API
  Future<List<Category>> loadCategories() async {
    try {
      return await _apiService.getCategories();
    } catch (e) {
      throw Exception('Erreur lors du chargement des catégories: $e');
    }
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

      await _apiService.createPost(
        imageFile: imageFile,
        name: name.trim(),
        description: description.trim(),
        categoryIds: categoryIds,
        isFree: isFree,
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