import 'package:flutter/foundation.dart';
import '../models/post.dart';

class PostsProvider extends ChangeNotifier {
  final List<Post> _posts = [
    Post(
      id: '1',
      authorId: '1',
      authorName: 'Alice Johnson',
      content: 'Just finished an amazing hike up Mount Rainier! The views were breathtaking.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      comments: 3,
    ),
    Post(
      id: '2',
      authorId: '2',
      authorName: 'Bob Smith',
      content: 'Tried a new pasta recipe today - homemade tagliatelle with truffle cream sauce. Turned out great!',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 8,
      comments: 5,
    ),
    Post(
      id: '3',
      authorId: '3',
      authorName: 'Carol Davis',
      content: 'Excited to announce I got accepted into the graduate program! Thanks everyone for the support.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 45,
      comments: 12,
    ),
    Post(
      id: '4',
      authorId: '4',
      authorName: 'David Lee',
      content: 'Jamming session in the backyard tonight. Anyone want to join?',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      likes: 6,
      comments: 4,
    ),
    Post(
      id: '5',
      authorId: '5',
      authorName: 'Emma Wilson',
      content: 'Beautiful sunset at the beach today. Sometimes you just need to stop and appreciate the moment.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likes: 22,
      comments: 7,
    ),
  ];

  List<Post> get posts => List.unmodifiable(_posts);

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        isLikedByMe: !post.isLikedByMe,
        likes: post.isLikedByMe ? post.likes - 1 : post.likes + 1,
      );
      notifyListeners();
    }
  }

  void removePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}
