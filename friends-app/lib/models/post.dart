class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLikedByMe;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.imageUrl,
    DateTime? createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLikedByMe = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLikedByMe,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}
