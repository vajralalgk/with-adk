import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../providers/posts_provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = context.watch<PostsProvider>().posts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: posts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dynamic_feed_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No posts yet',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _PostCard(post: posts[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Create Post',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    context.read<PostsProvider>().addPost(Post(
                          id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                          authorId: 'me',
                          authorName: 'You',
                          content: controller.text.trim(),
                        ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Post'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({required this.post});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  radius: 20,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : '?',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_timeAgo(post.createdAt),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (post.authorId == 'me')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () {
                      context.read<PostsProvider>().removePost(post.id);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    context.read<PostsProvider>().toggleLike(post.id);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isLikedByMe
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: post.isLikedByMe ? Colors.red : null,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likes}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.comment_outlined, size: 20),
                    const SizedBox(width: 4),
                    Text('${post.comments}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
