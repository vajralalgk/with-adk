enum FriendshipTier { acquaintance, casual, close, bestFriend, family }

class FriendshipHealth {
  final double score;
  final int interactionCount;
  final int daysConnected;
  final DateTime lastInteraction;
  final String trend;

  FriendshipHealth({
    required this.score,
    required this.interactionCount,
    required this.daysConnected,
    required this.lastInteraction,
    this.trend = 'stable',
  });

  String get scoreLabel {
    if (score >= 90) return 'Thriving';
    if (score >= 70) return 'Strong';
    if (score >= 50) return 'Good';
    if (score >= 30) return 'Needs Attention';
    return 'Fading';
  }

  String get scoreEmoji {
    if (score >= 90) return '💚';
    if (score >= 70) return '💙';
    if (score >= 50) return '💛';
    if (score >= 30) return '🧡';
    return '❤️‍🩹';
  }
}

class Friend {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final DateTime? birthday;
  final String? notes;
  final DateTime lastInteraction;
  final bool isFavorite;
  final FriendshipTier tier;
  final List<String> tags;
  final String? nickname;
  final String? relationship;
  final DateTime? friendSince;
  final bool isBlocked;
  final bool isMuted;

  Friend({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.avatarUrl,
    this.birthday,
    this.notes,
    DateTime? lastInteraction,
    this.isFavorite = false,
    this.tier = FriendshipTier.casual,
    this.tags = const [],
    this.nickname,
    this.relationship,
    DateTime? friendSince,
    this.isBlocked = false,
    this.isMuted = false,
  })  : lastInteraction = lastInteraction ?? DateTime.now(),
        friendSince = friendSince ?? DateTime.now();

  Friend copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    DateTime? birthday,
    String? notes,
    DateTime? lastInteraction,
    bool? isFavorite,
    FriendshipTier? tier,
    List<String>? tags,
    String? nickname,
    String? relationship,
    DateTime? friendSince,
    bool? isBlocked,
    bool? isMuted,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthday: birthday ?? this.birthday,
      notes: notes ?? this.notes,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      isFavorite: isFavorite ?? this.isFavorite,
      tier: tier ?? this.tier,
      tags: tags ?? this.tags,
      nickname: nickname ?? this.nickname,
      relationship: relationship ?? this.relationship,
      friendSince: friendSince ?? this.friendSince,
      isBlocked: isBlocked ?? this.isBlocked,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get displayName => nickname ?? name;

  String get tierLabel {
    switch (tier) {
      case FriendshipTier.acquaintance:
        return 'Acquaintance';
      case FriendshipTier.casual:
        return 'Casual Friend';
      case FriendshipTier.close:
        return 'Close Friend';
      case FriendshipTier.bestFriend:
        return 'Best Friend';
      case FriendshipTier.family:
        return 'Family';
    }
  }

  int get daysSinceLastInteraction =>
      DateTime.now().difference(lastInteraction).inDays;

  bool get needsAttention => daysSinceLastInteraction > 14;
}
