class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String userName;
  final String createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      content: json['content'],
      userName: json['userName'] ?? 'Utilisateur',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'userName': userName,
      'createdAt': createdAt,
    };
  }
}
