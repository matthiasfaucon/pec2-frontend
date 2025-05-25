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
      return data.map((post) => Post.fromJson(post)).toList();
    }

    throw Exception('Échec du chargement des posts: ${response.error}');
  }

  Future<Post> loadPostById(String postId) async {
    final response = await _apiService.request(
      method: 'get',
      endpoint: '/posts/$postId',
      withAuth: false,
    );
   
    if (response.success) {
      return Post.fromJson(response.data);
    }

    throw Exception('Échec du chargement du post: ${response.error}');
  }

}