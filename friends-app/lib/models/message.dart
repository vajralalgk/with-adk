class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

class Conversation {
  final String friendId;
  final String friendName;
  final List<Message> messages;

  Conversation({
    required this.friendId,
    required this.friendName,
    List<Message>? messages,
  }) : messages = messages ?? [];

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  int get unreadCount => messages.where((m) => !m.isRead && m.senderId == friendId).length;
}
