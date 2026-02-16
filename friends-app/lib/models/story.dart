enum MoodType { happy, excited, grateful, calm, thoughtful, sad, anxious, energetic }

enum StoryType { text, image, milestone, mood, location }

class Story {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final StoryType type;
  final MoodType? mood;
  final String? imageUrl;
  final String? location;
  final DateTime createdAt;
  final DateTime expiresAt;
  final List<String> viewedBy;
  final List<StoryReaction> reactions;
  final String? backgroundColor;

  Story({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.type = StoryType.text,
    this.mood,
    this.imageUrl,
    this.location,
    DateTime? createdAt,
    DateTime? expiresAt,
    this.viewedBy = const [],
    this.reactions = const [],
    this.backgroundColor,
  })  : createdAt = createdAt ?? DateTime.now(),
        expiresAt = expiresAt ?? DateTime.now().add(const Duration(hours: 24));

  Story copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    StoryType? type,
    MoodType? mood,
    String? imageUrl,
    String? location,
    DateTime? createdAt,
    DateTime? expiresAt,
    List<String>? viewedBy,
    List<StoryReaction>? reactions,
    String? backgroundColor,
  }) {
    return Story(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      type: type ?? this.type,
      mood: mood ?? this.mood,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewedBy: viewedBy ?? this.viewedBy,
      reactions: reactions ?? this.reactions,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get viewCount => viewedBy.length;

  String get moodLabel {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.excited:
        return 'Excited';
      case MoodType.grateful:
        return 'Grateful';
      case MoodType.calm:
        return 'Calm';
      case MoodType.thoughtful:
        return 'Thoughtful';
      case MoodType.sad:
        return 'Sad';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.energetic:
        return 'Energetic';
      case null:
        return '';
    }
  }

  String get moodEmoji {
    switch (mood) {
      case MoodType.happy:
        return '😊';
      case MoodType.excited:
        return '🎉';
      case MoodType.grateful:
        return '🙏';
      case MoodType.calm:
        return '😌';
      case MoodType.thoughtful:
        return '🤔';
      case MoodType.sad:
        return '😢';
      case MoodType.anxious:
        return '😰';
      case MoodType.energetic:
        return '⚡';
      case null:
        return '';
    }
  }
}

class StoryReaction {
  final String userId;
  final String emoji;
  final DateTime timestamp;

  StoryReaction({
    required this.userId,
    required this.emoji,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class Milestone {
  final String id;
  final String friendId;
  final String friendName;
  final String title;
  final String? description;
  final DateTime date;
  final String icon;
  final String category;

  Milestone({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.title,
    this.description,
    required this.date,
    this.icon = '🎯',
    this.category = 'general',
  });

  Milestone copyWith({
    String? id,
    String? friendId,
    String? friendName,
    String? title,
    String? description,
    DateTime? date,
    String? icon,
    String? category,
  }) {
    return Milestone(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      icon: icon ?? this.icon,
      category: category ?? this.category,
    );
  }
}
