enum EventType { meetup, birthday, call, message, custom }

class FriendEvent {
  final String id;
  final String friendId;
  final String friendName;
  final EventType type;
  final String title;
  final String? description;
  final DateTime date;
  final bool isCompleted;

  FriendEvent({
    required this.id,
    required this.friendId,
    required this.friendName,
    required this.type,
    required this.title,
    this.description,
    required this.date,
    this.isCompleted = false,
  });

  FriendEvent copyWith({
    String? id,
    String? friendId,
    String? friendName,
    EventType? type,
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
  }) {
    return FriendEvent(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  String get typeLabel {
    switch (type) {
      case EventType.meetup:
        return 'Meetup';
      case EventType.birthday:
        return 'Birthday';
      case EventType.call:
        return 'Call';
      case EventType.message:
        return 'Message';
      case EventType.custom:
        return 'Event';
    }
  }
}
