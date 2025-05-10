import 'package:firstflutterapp/interfaces/category.dart';

class Post {
  final String id;
  final String userId;
  final String name;
  final String pictureUrl;
  final bool isFree;
  final bool enable;
  final List<Category> categories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Post({
    required this.id,
    required this.userId,
    required this.name,
    required this.pictureUrl,
    this.isFree = false,
    this.enable = true,
    this.categories = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      pictureUrl: json['pictureUrl'],
      isFree: json['isFree'] ?? false,
      enable: json['enable'] ?? true,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((category) => Category.fromJson(category))
          .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'picture_url': pictureUrl,
      'is_free': isFree,
      'enable': enable,
      'categories': categories.map((category) => category.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}