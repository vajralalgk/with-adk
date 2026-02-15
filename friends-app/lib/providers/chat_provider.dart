import 'package:flutter/foundation.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  static const String _currentUserId = 'me';

  final Map<String, Conversation> _conversations = {
    '1': Conversation(
      friendId: '1',
      friendName: 'Alice Johnson',
      messages: [
        Message(
          id: 'm1',
          senderId: '1',
          receiverId: _currentUserId,
          content: 'Hey! Are you coming to the hike this weekend?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          isRead: true,
        ),
        Message(
          id: 'm2',
          senderId: _currentUserId,
          receiverId: '1',
          content: 'Absolutely! What time should I be there?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
          isRead: true,
        ),
        Message(
          id: 'm3',
          senderId: '1',
          receiverId: _currentUserId,
          content: 'Let\'s meet at 7 AM at the trailhead. Bring water!',
          timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        ),
      ],
    ),
    '2': Conversation(
      friendId: '2',
      friendName: 'Bob Smith',
      messages: [
        Message(
          id: 'm4',
          senderId: '2',
          receiverId: _currentUserId,
          content: 'I\'ll share that recipe with you tomorrow',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
      ],
    ),
    '3': Conversation(
      friendId: '3',
      friendName: 'Carol Davis',
      messages: [
        Message(
          id: 'm5',
          senderId: _currentUserId,
          receiverId: '3',
          content: 'Congrats on the acceptance! So proud of you!',
          timestamp: DateTime.now().subtract(const Duration(hours: 12)),
          isRead: true,
        ),
        Message(
          id: 'm6',
          senderId: '3',
          receiverId: _currentUserId,
          content: 'Thank you so much! We should celebrate soon!',
          timestamp: DateTime.now().subtract(const Duration(hours: 11)),
        ),
      ],
    ),
  };

  String get currentUserId => _currentUserId;

  List<Conversation> get conversations {
    final list = _conversations.values.toList();
    list.sort((a, b) {
      final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
      final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  Conversation? getConversation(String friendId) => _conversations[friendId];

  int get totalUnread =>
      _conversations.values.fold(0, (sum, c) => sum + c.unreadCount);

  void sendMessage(String friendId, String friendName, String content) {
    if (!_conversations.containsKey(friendId)) {
      _conversations[friendId] = Conversation(
        friendId: friendId,
        friendName: friendName,
      );
    }

    final conversation = _conversations[friendId]!;
    conversation.messages.add(Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId,
      receiverId: friendId,
      content: content,
      isRead: true,
    ));
    notifyListeners();
  }

  void markAsRead(String friendId) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;

    for (var i = 0; i < conversation.messages.length; i++) {
      if (!conversation.messages[i].isRead &&
          conversation.messages[i].senderId == friendId) {
        conversation.messages[i] =
            conversation.messages[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }
}
