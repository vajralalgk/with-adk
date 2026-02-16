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
      location: 'Mount Rainier',
      tags: ['hiking', 'nature'],
      commentList: [
        PostComment(
          id: 'c1',
          authorId: '2',
          authorName: 'Bob Smith',
          content: 'That looks amazing! I need to come next time.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        PostComment(
          id: 'c2',
          authorId: '4',
          authorName: 'David Lee',
          content: 'The weather was perfect for it!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        PostComment(
          id: 'c3',
          authorId: 'me',
          authorName: 'You',
          content: 'Wish I could have joined!',
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
    Post(
      id: '2',
      authorId: '2',
      authorName: 'Bob Smith',
      content: 'Tried a new pasta recipe today - homemade tagliatelle with truffle cream sauce. Turned out great!',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 8,
      comments: 5,
      tags: ['cooking', 'food'],
      commentList: [
        PostComment(
          id: 'c4',
          authorId: '1',
          authorName: 'Alice Johnson',
          content: 'Recipe please! That sounds delicious.',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
    ),
    Post(
      id: '3',
      authorId: '3',
      authorName: 'Carol Davis',
      content: 'Excited to announce I got accepted into the graduate program! Thanks everyone for the support.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 45,
      comments: 12,
      tags: ['achievement', 'education'],
    ),
    Post(
      id: '4',
      authorId: '4',
      authorName: 'David Lee',
      content: 'Jamming session in the backyard tonight. Anyone want to join?',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      likes: 6,
      comments: 4,
      tags: ['music'],
    ),
    Post(
      id: '5',
      authorId: '5',
      authorName: 'Emma Wilson',
      content: 'Beautiful sunset at the beach today. Sometimes you just need to stop and appreciate the moment.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likes: 22,
      comments: 7,
      location: 'Malibu Beach',
      tags: ['sunset', 'beach', 'nature'],
    ),
  ];

  List<Post> get posts => List.unmodifiable(_posts);

  List<Post> get bookmarkedPosts =>
      _posts.where((p) => p.isBookmarked).toList();

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

  void toggleBookmark(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        isBookmarked: !_posts[index].isBookmarked,
      );
      notifyListeners();
    }
  }

  void addComment(String postId, PostComment comment) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final comments = List<PostComment>.from(post.commentList);
      comments.add(comment);
      _posts[index] = post.copyWith(
        commentList: comments,
        comments: post.comments + 1,
      );
      notifyListeners();
    }
  }

  void removeComment(String postId, String commentId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final comments = post.commentList.where((c) => c.id != commentId).toList();
      _posts[index] = post.copyWith(
        commentList: comments,
        comments: post.comments - 1,
      );
      notifyListeners();
    }
  }

  List<Post> search(String query) {
    final lower = query.toLowerCase();
    return _posts
        .where((p) =>
            p.content.toLowerCase().contains(lower) ||
            p.authorName.toLowerCase().contains(lower) ||
            p.tags.any((t) => t.toLowerCase().contains(lower)))
        .toList();
  }

  List<Post> getPostsByAuthor(String authorId) =>
      _posts.where((p) => p.authorId == authorId).toList();
}
