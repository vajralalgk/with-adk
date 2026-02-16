import 'package:flutter/foundation.dart';
import '../models/story.dart';

class StoryProvider extends ChangeNotifier {
  final List<Story> _stories = [
    Story(
      id: 's1',
      authorId: '1',
      authorName: 'Alice Johnson',
      content: 'Summit reached! The view from up here is incredible.',
      type: StoryType.text,
      mood: MoodType.excited,
      location: 'Mount Rainier',
      backgroundColor: '#FF6B6B',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Story(
      id: 's2',
      authorId: '3',
      authorName: 'Carol Davis',
      content: 'Officially a graduate student! New chapter begins.',
      type: StoryType.milestone,
      mood: MoodType.happy,
      backgroundColor: '#4ECDC4',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Story(
      id: 's3',
      authorId: '2',
      authorName: 'Bob Smith',
      content: 'Perfecting my grandmother\'s secret pasta recipe today.',
      type: StoryType.text,
      mood: MoodType.calm,
      backgroundColor: '#45B7D1',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Story(
      id: 's4',
      authorId: '4',
      authorName: 'David Lee',
      content: 'Late night guitar session. Music heals everything.',
      type: StoryType.mood,
      mood: MoodType.thoughtful,
      backgroundColor: '#96CEB4',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    Story(
      id: 's5',
      authorId: '5',
      authorName: 'Emma Wilson',
      content: 'Grateful for the most beautiful sunset I\'ve ever seen.',
      type: StoryType.text,
      mood: MoodType.grateful,
      location: 'Malibu Beach',
      backgroundColor: '#FFEAA7',
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
    ),
    Story(
      id: 's6',
      authorId: 'me',
      authorName: 'You',
      content: 'Building the future, one line of code at a time.',
      type: StoryType.text,
      mood: MoodType.energetic,
      backgroundColor: '#A29BFE',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final List<Milestone> _milestones = [
    Milestone(
      id: 'ml1',
      friendId: '1',
      friendName: 'Alice Johnson',
      title: '1 Year of Friendship',
      description: 'You\'ve been friends for a whole year!',
      date: DateTime.now().subtract(const Duration(days: 30)),
      icon: '🎉',
      category: 'anniversary',
    ),
    Milestone(
      id: 'ml2',
      friendId: '3',
      friendName: 'Carol Davis',
      title: 'Grad School Acceptance',
      description: 'Carol got into the graduate program!',
      date: DateTime.now().subtract(const Duration(days: 2)),
      icon: '🎓',
      category: 'achievement',
    ),
    Milestone(
      id: 'ml3',
      friendId: '2',
      friendName: 'Bob Smith',
      title: '100 Messages Exchanged',
      description: 'You\'ve chatted over 100 times!',
      date: DateTime.now().subtract(const Duration(days: 10)),
      icon: '💬',
      category: 'interaction',
    ),
  ];

  List<Story> get stories => _stories
      .where((s) => !s.isExpired)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Story> get allStories => List.unmodifiable(_stories);

  List<Story> get myStories => _stories
      .where((s) => s.authorId == 'me' && !s.isExpired)
      .toList();

  List<Milestone> get milestones => List.unmodifiable(_milestones)
    ..sort((a, b) => b.date.compareTo(a.date));

  Map<String, List<Story>> get storiesByAuthor {
    final map = <String, List<Story>>{};
    for (final story in stories) {
      map.putIfAbsent(story.authorId, () => []).add(story);
    }
    return map;
  }

  void addStory(Story story) {
    _stories.insert(0, story);
    notifyListeners();
  }

  void removeStory(String storyId) {
    _stories.removeWhere((s) => s.id == storyId);
    notifyListeners();
  }

  void addReaction(String storyId, StoryReaction reaction) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index == -1) return;

    final reactions = List<StoryReaction>.from(_stories[index].reactions);
    reactions.add(reaction);
    _stories[index] = _stories[index].copyWith(reactions: reactions);
    notifyListeners();
  }

  void markViewed(String storyId, String userId) {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index == -1) return;

    if (!_stories[index].viewedBy.contains(userId)) {
      final viewedBy = List<String>.from(_stories[index].viewedBy);
      viewedBy.add(userId);
      _stories[index] = _stories[index].copyWith(viewedBy: viewedBy);
      notifyListeners();
    }
  }

  void addMilestone(Milestone milestone) {
    _milestones.add(milestone);
    notifyListeners();
  }

  List<Story> getStoriesForFriend(String friendId) =>
      _stories.where((s) => s.authorId == friendId && !s.isExpired).toList();

  MoodType? getLatestMood(String friendId) {
    final friendStories = _stories
        .where((s) => s.authorId == friendId && s.mood != null && !s.isExpired)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return friendStories.isNotEmpty ? friendStories.first.mood : null;
  }
}
