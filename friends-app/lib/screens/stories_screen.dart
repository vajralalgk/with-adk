import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../providers/story_provider.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final storiesByAuthor = storyProvider.storiesByAuthor;
    final myStories = storyProvider.myStories;
    final milestones = storyProvider.milestones;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories & Moments'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // My Story
          Card(
            child: ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    radius: 24,
                    child: Text(
                      'Y',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: colorScheme.primary,
                      child: Icon(Icons.add, size: 14, color: colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
              title: const Text('My Story'),
              subtitle: Text(
                myStories.isNotEmpty
                    ? '${myStories.length} active ${myStories.length == 1 ? 'story' : 'stories'}'
                    : 'Tap to add a story',
              ),
              onTap: () => _showCreateStoryDialog(context),
            ),
          ),
          const SizedBox(height: 16),
          // Friends' Stories
          if (storiesByAuthor.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Friends\' Stories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: storiesByAuthor.entries
                    .where((e) => e.key != 'me')
                    .map((entry) {
                  final stories = entry.value;
                  final latestStory = stories.first;
                  return GestureDetector(
                    onTap: () => _showStoryViewer(context, stories),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                latestStory.authorName.isNotEmpty
                                    ? latestStory.authorName[0]
                                    : '?',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 70,
                            child: Text(
                              latestStory.authorName.split(' ').first,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const Divider(),
          // Recent Stories Feed
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Recent Updates',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
          ),
          ...storyProvider.stories.map((story) => _StoryCard(story: story)),
          // Milestones Section
          if (milestones.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Milestones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ),
            ...milestones.map((m) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Text(m.icon, style: const TextStyle(fontSize: 28)),
                    title: Text(m.title),
                    subtitle: Text(m.friendName),
                    trailing: Text(
                      _timeAgo(m.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateStoryDialog(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _showStoryViewer(BuildContext context, List<Story> stories) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return _StoryViewerDialog(stories: stories);
      },
    );
  }

  void _showCreateStoryDialog(BuildContext context) {
    final contentController = TextEditingController();
    MoodType? selectedMood;
    StoryType selectedType = StoryType.text;
    String selectedColor = '#A29BFE';

    final colors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
      '#FFEAA7', '#A29BFE', '#FD79A8', '#636E72',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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
                  Text('Create Story',
                      style: Theme.of(ctx).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'What\'s happening?',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  Text('How are you feeling?',
                      style: Theme.of(ctx).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: MoodType.values.map((mood) {
                      final story = Story(
                        id: '', authorId: '', authorName: '',
                        content: '', mood: mood,
                      );
                      return ChoiceChip(
                        label: Text('${story.moodEmoji} ${story.moodLabel}'),
                        selected: selectedMood == mood,
                        onSelected: (val) {
                          setModalState(() => selectedMood = val ? mood : null);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Text('Background Color',
                      style: Theme.of(ctx).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: selectedColor == color
                                ? [BoxShadow(
                                    color: _parseColor(color).withOpacity(0.5),
                                    blurRadius: 8,
                                  )]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (contentController.text.trim().isNotEmpty) {
                        context.read<StoryProvider>().addStory(Story(
                              id: 'story_${DateTime.now().millisecondsSinceEpoch}',
                              authorId: 'me',
                              authorName: 'You',
                              content: contentController.text.trim(),
                              type: selectedType,
                              mood: selectedMood,
                              backgroundColor: selectedColor,
                            ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Share Story'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

class _StoryCard extends StatelessWidget {
  final Story story;

  const _StoryCard({required this.story});

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = story.backgroundColor != null
        ? _parseColor(story.backgroundColor!)
        : Theme.of(context).colorScheme.primaryContainer;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    story.authorName.isNotEmpty ? story.authorName[0] : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _timeAgo(story.createdAt),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (story.mood != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${story.moodEmoji} ${story.moodLabel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              story.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (story.location != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    story.location!,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.visibility,
                    size: 14, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  '${story.viewCount} views',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (story.reactions.isNotEmpty) ...[
                  Text(
                    '${story.reactions.length} reactions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryViewerDialog extends StatefulWidget {
  final List<Story> stories;

  const _StoryViewerDialog({required this.stories});

  @override
  State<_StoryViewerDialog> createState() => _StoryViewerDialogState();
}

class _StoryViewerDialogState extends State<_StoryViewerDialog> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];
    final bgColor = story.backgroundColor != null
        ? Color(int.parse(story.backgroundColor!.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primaryContainer;

    return Dialog.fullscreen(
      backgroundColor: bgColor,
      child: SafeArea(
        child: GestureDetector(
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx > width / 2) {
              if (_currentIndex < widget.stories.length - 1) {
                setState(() => _currentIndex++);
              } else {
                Navigator.pop(context);
              }
            } else {
              if (_currentIndex > 0) {
                setState(() => _currentIndex--);
              }
            }
          },
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (story.mood != null)
                        Text(
                          story.moodEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        story.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (story.location != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(story.location!,
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Progress bar at top
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Row(
                  children: List.generate(widget.stories.length, (i) {
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _currentIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Author info
              Positioned(
                top: 20,
                left: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        story.authorName.isNotEmpty ? story.authorName[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      story.authorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
