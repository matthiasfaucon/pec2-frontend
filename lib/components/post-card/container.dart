import 'dart:io';
import 'package:firstflutterapp/interfaces/post.dart';
import 'package:firstflutterapp/components/comments/comments_modal.dart';
import 'package:firstflutterapp/components/comments/comment_badge.dart';
import 'package:firstflutterapp/services/api_service.dart';
import 'package:flutter/material.dart';

final ApiService _apiService = ApiService();

class PostCard extends StatelessWidget {
  final Post post;
  final bool isSSEConnected;
  final Function(String)? onPostUpdated;

  const PostCard({
    Key? key,
    required this.post,
    required this.isSSEConnected,
    this.onPostUpdated,
  }) : super(key: key);

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  void _openCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return CommentsModal(
              post: post,
              isConnected: isSSEConnected,
              postAuthorName: post.user.userName,
            );
          },
        );
      },
    );
  }
  Future toggleLike(String postId) async {
    final response = await _apiService.request(
      method: 'post',
      endpoint: '/posts/$postId/like',
      withAuth: true,
    );

    if (response.success) {
      return response.data;
    }

    throw Exception('Échec de l\'ajout du like: ${response.error}');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with username and timestamp
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      post.user.profilePicture != null
                          ? NetworkImage(post.user.profilePicture)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      getFormattedDate(post.updatedAt),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.report_outlined),
                  onPressed: () {
                    // Là je mettrais la logique pour signaler le post
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              try {
                await toggleLike(post.id);
                // We need to notify parent to update posts list
                if (onPostUpdated != null) {
                  onPostUpdated!(post.id);
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
            child: Container(
              constraints: const BoxConstraints(maxHeight: 400),
              width: double.infinity,
              child: Image(
                image:
                    post.pictureUrl != null
                        ? NetworkImage(post.pictureUrl)
                        : const AssetImage('assets/images/default_image.png')
                            as ImageProvider,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                    ),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),

          // Post caption
          if (post.name.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(post.name, style: const TextStyle(fontSize: 15)),
            ),

          // Like and comment actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    try {
                      await toggleLike(post.id);
                      // We need to notify parent to update posts list
                      if (onPostUpdated != null) {
                        onPostUpdated!(post.id);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                    }
                  },
                ),
                Text(
                  post.likesCount.toString(),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 8),
                CommentBadge(
                  count: post.comments.length,
                  onTap: () => _openCommentsModal(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
