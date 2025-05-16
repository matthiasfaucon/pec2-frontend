import 'package:firstflutterapp/components/post-card/container.dart';
import 'package:firstflutterapp/interfaces/post.dart';
import 'package:firstflutterapp/services/sse_service.dart';
import 'package:firstflutterapp/screens/home/home-service.dart';
import 'package:flutter/material.dart';

class FreeFeed extends StatefulWidget {
  @override
  _FreeFeedState createState() => _FreeFeedState();
}

class _FreeFeedState extends State<FreeFeed> {
  bool _isLoading = false;
  List<Post> _posts = [];
  final PostsListingService _postListingService = PostsListingService();
  final Map<String, SSEService> _sseServices = {};
  final Map<String, bool> _sseConnections = {};

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
      });
      for (final post in posts) {
        _initSSEForPost(post.id);
      
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
            return PostCard(
              post: post,
              isSSEConnected: _sseConnections[post.id] ?? false,
            );
              
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildForYouSection();
  }
}
