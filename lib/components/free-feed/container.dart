import 'package:firstflutterapp/interfaces/comment.dart';
import 'package:firstflutterapp/interfaces/post.dart';
import 'package:firstflutterapp/services/sse_service.dart';
import 'package:firstflutterapp/view/home/home-service.dart';
import 'package:flutter/material.dart';

class FreeFeed extends StatefulWidget {
  @override
  _FreeFeedState createState() => _FreeFeedState();
}

class _FreeFeedState extends State<FreeFeed> {
  bool _isLoading = false;
  List<Post> _posts = [];
  final PostsListingService _postListingService = PostsListingService();  final Map<String, SSEService> _sseServices = {};
  final Map<String, bool> _sseConnections = {};
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }
  @override
  void dispose() {
    for (final service in _sseServices.values) {
      service.disconnect();
    }
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await _postListingService.loadPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });      for (final post in posts) {
        _initSSEForPost(post.id);
        _commentControllers[post.id] = TextEditingController();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des posts: $e')),
        );
      }
    }
  }
  void _initSSEForPost(String postId) {
    final sseService = SSEService(
      postId: postId,
      onNewComment: (comment) {
        setState(() {
          for (final post in _posts) {
            if (post.id == postId) {
              post.comments.add(comment);
              break;
            }
          }
        });
      },
      onExistingComments: (comments) {
        setState(() {
          for (final post in _posts) {
            if (post.id == postId) {
              post.comments.addAll(comments);
              break;
            }
          }
        });
      },
      onConnectionStatusChanged: (isConnected) {
        setState(() {
          _sseConnections[postId] = isConnected;
        });
      },
    );

    _sseServices[postId] = sseService;

    sseService.connect().catchError((error) {
      print('Erreur de connexion SSE: $error');
    });
  }

  Widget _buildForYouSection() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pour vous",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _posts.length,
          itemBuilder: (_, index) {
            final post = _posts[index];
            return _buildPostCard(post);
          },
        ),
      ],
    );
  }
  Widget _buildPostCard(Post post) {
    final bool isSSEConnected = _sseConnections[post.id] ?? false;
    final commentController = _commentControllers[post.id] ?? TextEditingController();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.network(
              post.pictureUrl,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up),
                onPressed: () {},
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {},
                  ),                  Icon(
                    isSSEConnected ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: isSSEConnected ? Colors.green : Colors.red,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.report),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              post.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (post.comments.isNotEmpty)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Commentaires (${post.comments.length})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(comment.userName.isNotEmpty
                              ? comment.userName[0].toUpperCase()
                              : '?'),
                        ),
                        title: Text(comment.userName),
                        subtitle: Text(comment.content),
                        dense: true,
                      );
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: isSSEConnected
                      ? () {
                          if (commentController.text.trim().isNotEmpty) {
                            _sseServices[post.id]?.sendComment(
                                commentController.text.trim());
                            commentController.clear();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildForYouSection();
  }
}
