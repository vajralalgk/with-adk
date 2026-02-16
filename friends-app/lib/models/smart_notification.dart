enum NotificationType {
  birthdayReminder,
  friendshipAnniversary,
  reconnectSuggestion,
  eventReminder,
  groupActivity,
  storyReaction,
  aiInsight,
  milestoneReached,
}

enum NotificationPriority { low, medium, high, urgent }

class SmartNotification {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final String? actionLabel;
  final String? targetId;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final bool isRead;
  final bool isDismissed;
  final Map<String, String> metadata;

  SmartNotification({
    required this.id,
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.title,
    required this.body,
    this.actionLabel,
    this.targetId,
    DateTime? createdAt,
    this.scheduledFor,
    this.isRead = false,
    this.isDismissed = false,
    this.metadata = const {},
  }) : createdAt = createdAt ?? DateTime.now();

  SmartNotification copyWith({
    String? id,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    String? actionLabel,
    String? targetId,
    DateTime? createdAt,
    DateTime? scheduledFor,
    bool? isRead,
    bool? isDismissed,
    Map<String, String>? metadata,
  }) {
    return SmartNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      actionLabel: actionLabel ?? this.actionLabel,
      targetId: targetId ?? this.targetId,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      metadata: metadata ?? this.metadata,
    );
  }

  String get typeLabel {
    switch (type) {
      case NotificationType.birthdayReminder:
        return 'Birthday';
      case NotificationType.friendshipAnniversary:
        return 'Anniversary';
      case NotificationType.reconnectSuggestion:
        return 'Reconnect';
      case NotificationType.eventReminder:
        return 'Event';
      case NotificationType.groupActivity:
        return 'Group';
      case NotificationType.storyReaction:
        return 'Story';
      case NotificationType.aiInsight:
        return 'AI Insight';
      case NotificationType.milestoneReached:
        return 'Milestone';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.birthdayReminder:
        return '🎂';
      case NotificationType.friendshipAnniversary:
        return '🎊';
      case NotificationType.reconnectSuggestion:
        return '👋';
      case NotificationType.eventReminder:
        return '📅';
      case NotificationType.groupActivity:
        return '👥';
      case NotificationType.storyReaction:
        return '💫';
      case NotificationType.aiInsight:
        return '🤖';
      case NotificationType.milestoneReached:
        return '🏆';
    }
  }
}

class ReminderRule {
  final String id;
  final String name;
  final String description;
  final Duration interval;
  final bool isEnabled;
  final List<String> friendIds;

  ReminderRule({
    required this.id,
    required this.name,
    required this.description,
    required this.interval,
    this.isEnabled = true,
    this.friendIds = const [],
  });

  ReminderRule copyWith({
    String? id,
    String? name,
    String? description,
    Duration? interval,
    bool? isEnabled,
    List<String>? friendIds,
  }) {
    return ReminderRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      interval: interval ?? this.interval,
      isEnabled: isEnabled ?? this.isEnabled,
      friendIds: friendIds ?? this.friendIds,
    );
  }
}
