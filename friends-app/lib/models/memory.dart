enum MemoryType { photo, chat, event, milestone, location, note }

class Memory {
  final String id;
  final String friendId;
  final String friendName;
  final MemoryType type;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime date;
  final String? location;
  final List<String> tags;
  final bool isFavorite;

  Memory({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    required this.date,
    this.location,
    this.tags = const [],
    this.isFavorite = false,
  });

  Memory copyWith({
    String? id,
    String? friendId,
    String? friendName,
    MemoryType? type,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? date,
    String? location,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Memory(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get typeLabel {
    switch (type) {
      case MemoryType.photo:
        return 'Photo';
      case MemoryType.chat:
        return 'Chat Highlight';
      case MemoryType.event:
        return 'Event';
      case MemoryType.milestone:
        return 'Milestone';
      case MemoryType.location:
        return 'Place';
      case MemoryType.note:
        return 'Note';
    }
  }

  String get typeIcon {
    switch (type) {
      case MemoryType.photo:
        return '📸';
      case MemoryType.chat:
        return '💬';
      case MemoryType.event:
        return '🎉';
      case MemoryType.milestone:
        return '🏆';
      case MemoryType.location:
        return '📍';
      case MemoryType.note:
        return '📝';
    }
  }
}

class SharedTimeline {
  final String friendId;
  final String friendName;
  final List<Memory> memories;
  final DateTime friendshipStartDate;

  SharedTimeline({
    required this.friendId,
    required this.friendName,
    required this.memories,
    required this.friendshipStartDate,
  });

  Duration get friendshipDuration =>
      DateTime.now().difference(friendshipStartDate);

  int get totalMemories => memories.length;

  List<Memory> get favoriteMemories =>
      memories.where((m) => m.isFavorite).toList();

  Map<int, List<Memory>> get memoriesByYear {
    final map = <int, List<Memory>>{};
    for (final memory in memories) {
      map.putIfAbsent(memory.date.year, () => []).add(memory);
    }
    return map;
  }
}
