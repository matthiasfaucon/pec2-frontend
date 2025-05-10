import 'dart:io';
import 'package:firstflutterapp/interfaces/category.dart';
import 'package:firstflutterapp/interfaces/post.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class PostsListingService {
  final ApiService _apiService = ApiService();

  Future<List<Post>> loadPosts() async {
    final response = await _apiService.request(
      method: 'get',
      endpoint: '/posts',
      withAuth: false,
    );
   
    if (response.success) {
      final List<dynamic> data = response.data;
      print(data);
      return data.map((post) => Post.fromJson(post)).toList();
    }

    throw Exception('Échec du chargement des posts: ${response.error}');
  }

}