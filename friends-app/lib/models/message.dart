enum ChatMessageType { text, image, voice, location, file, poll, system }

class MessageReaction {
  final String userId;
  final String emoji;
  final DateTime timestamp;

  MessageReaction({
    required this.userId,
    required this.emoji,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final ChatMessageType type;
  final List<MessageReaction> reactions;
  final String? replyToId;
  final bool isStarred;
  final bool isDeleted;
  final int? voiceDurationSeconds;
  final String? attachmentUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    DateTime? timestamp,
    this.isRead = false,
    this.type = ChatMessageType.text,
    this.reactions = const [],
    this.replyToId,
    this.isStarred = false,
    this.isDeleted = false,
    this.voiceDurationSeconds,
    this.attachmentUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    ChatMessageType? type,
    List<MessageReaction>? reactions,
    String? replyToId,
    bool? isStarred,
    bool? isDeleted,
    int? voiceDurationSeconds,
    String? attachmentUrl,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      isStarred: isStarred ?? this.isStarred,
      isDeleted: isDeleted ?? this.isDeleted,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  bool get hasReactions => reactions.isNotEmpty;

  Map<String, int> get reactionCounts {
    final counts = <String, int>{};
    for (final reaction in reactions) {
      counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
    }
    return counts;
  }
}

class Conversation {
  final String friendId;
  final String friendName;
  final List<Message> messages;
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;

  Conversation({
    required this.friendId,
    required this.friendName,
    List<Message>? messages,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
  }) : messages = messages ?? [];

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  int get unreadCount =>
      messages.where((m) => !m.isRead && m.senderId == friendId).length;

  List<Message> get starredMessages =>
      messages.where((m) => m.isStarred).toList();

  List<Message> searchMessages(String query) {
    final lower = query.toLowerCase();
    return messages
        .where((m) => m.content.toLowerCase().contains(lower))
        .toList();
  }
}
