import 'package:flutter/foundation.dart';
import '../models/smart_notification.dart';

class NotificationProvider extends ChangeNotifier {
  final List<SmartNotification> _notifications = [
    SmartNotification(
      id: 'n1',
      type: NotificationType.birthdayReminder,
      priority: NotificationPriority.high,
      title: 'Carol\'s Birthday is Coming!',
      body: 'Carol Davis turns 29 on November 8th. Start planning something special!',
      actionLabel: 'Send Wishes',
      targetId: '3',
      scheduledFor: DateTime(DateTime.now().year, 11, 5),
    ),
    SmartNotification(
      id: 'n2',
      type: NotificationType.reconnectSuggestion,
      priority: NotificationPriority.medium,
      title: 'Reconnect with Emma',
      body: 'You haven\'t chatted with Emma Wilson in 2 weeks. How about saying hi?',
      actionLabel: 'Send Message',
      targetId: '5',
    ),
    SmartNotification(
      id: 'n3',
      type: NotificationType.aiInsight,
      priority: NotificationPriority.low,
      title: 'Friendship Insight',
      body: 'Your friendship with Alice is thriving! You\'ve interacted 15 times this month - that\'s 40% more than last month.',
      targetId: '1',
    ),
    SmartNotification(
      id: 'n4',
      type: NotificationType.eventReminder,
      priority: NotificationPriority.high,
      title: 'Weekend Hike Tomorrow',
      body: 'Don\'t forget your hike at Mount Rainier trailhead with Alice tomorrow at 7 AM!',
      actionLabel: 'View Event',
      targetId: 'e1',
    ),
    SmartNotification(
      id: 'n5',
      type: NotificationType.milestoneReached,
      priority: NotificationPriority.medium,
      title: '100 Messages with Bob!',
      body: 'You\'ve exchanged over 100 messages with Bob Smith. That\'s a milestone worth celebrating!',
      targetId: '2',
    ),
    SmartNotification(
      id: 'n6',
      type: NotificationType.groupActivity,
      priority: NotificationPriority.low,
      title: 'Weekend Hikers is Active',
      body: '3 new messages in your Weekend Hikers group. Don\'t miss the plans!',
      actionLabel: 'Open Group',
      targetId: 'g1',
    ),
    SmartNotification(
      id: 'n7',
      type: NotificationType.friendshipAnniversary,
      priority: NotificationPriority.medium,
      title: '1 Year with Alice!',
      body: 'You and Alice Johnson have been friends for a year! Celebrate this milestone.',
      actionLabel: 'Send a Note',
      targetId: '1',
    ),
  ];

  final List<ReminderRule> _rules = [
    ReminderRule(
      id: 'r1',
      name: 'Weekly Check-in',
      description: 'Remind me to check in with close friends weekly',
      interval: const Duration(days: 7),
    ),
    ReminderRule(
      id: 'r2',
      name: 'Birthday Alerts',
      description: 'Notify 3 days before a friend\'s birthday',
      interval: const Duration(days: 3),
    ),
    ReminderRule(
      id: 'r3',
      name: 'Reconnect Nudge',
      description: 'Suggest reconnecting after 14 days of no interaction',
      interval: const Duration(days: 14),
    ),
  ];

  List<SmartNotification> get notifications =>
      _notifications.where((n) => !n.isDismissed).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<SmartNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  List<ReminderRule> get rules => List.unmodifiable(_rules);

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  void dismiss(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isDismissed: true);
    notifyListeners();
  }

  void addNotification(SmartNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void toggleRule(String ruleId) {
    final index = _rules.indexWhere((r) => r.id == ruleId);
    if (index == -1) return;
    _rules[index] = _rules[index].copyWith(isEnabled: !_rules[index].isEnabled);
    notifyListeners();
  }

  void addRule(ReminderRule rule) {
    _rules.add(rule);
    notifyListeners();
  }

  void removeRule(String ruleId) {
    _rules.removeWhere((r) => r.id == ruleId);
    notifyListeners();
  }
}
