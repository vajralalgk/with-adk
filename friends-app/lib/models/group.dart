enum GroupRole { owner, admin, member }

class GroupMember {
  final String friendId;
  final String name;
  final GroupRole role;
  final DateTime joinedAt;

  GroupMember({
    required this.friendId,
    required this.name,
    this.role = GroupRole.member,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  GroupMember copyWith({
    String? friendId,
    String? name,
    GroupRole? role,
    DateTime? joinedAt,
  }) {
    return GroupMember(
      friendId: friendId ?? this.friendId,
      name: name ?? this.name,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class GroupMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final List<String> reactions;
  final String? replyToId;

  GroupMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    DateTime? timestamp,
    this.type = MessageType.text,
    this.reactions = const [],
    this.replyToId,
  }) : timestamp = timestamp ?? DateTime.now();

  GroupMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    MessageType? type,
    List<String>? reactions,
    String? replyToId,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
    );
  }
}

enum MessageType { text, image, voice, location, poll, file }

class Group {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final List<GroupMember> members;
  final List<GroupMessage> messages;
  final DateTime createdAt;
  final bool isMuted;
  final bool isPinned;

  Group({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    this.members = const [],
    this.messages = const [],
    DateTime? createdAt,
    this.isMuted = false,
    this.isPinned = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    List<GroupMember>? members,
    List<GroupMessage>? messages,
    DateTime? createdAt,
    bool? isMuted,
    bool? isPinned,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      members: members ?? this.members,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  GroupMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  int get memberCount => members.length;

  String get memberNames => members.map((m) => m.name).join(', ');
}

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final String createdBy;
  final DateTime createdAt;
  final bool isAnonymous;
  final bool allowMultiple;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.createdBy,
    DateTime? createdAt,
    this.isAnonymous = false,
    this.allowMultiple = false,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes.length);
}

class PollOption {
  final String id;
  final String text;
  final List<String> votes;

  PollOption({
    required this.id,
    required this.text,
    this.votes = const [],
  });

  PollOption copyWith({
    String? id,
    String? text,
    List<String>? votes,
  }) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }
}
