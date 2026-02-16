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
    final list = _conversations.values
        .where((c) => !c.isArchived)
        .toList();
    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
      final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return list;
  }

  List<Conversation> get archivedConversations =>
      _conversations.values.where((c) => c.isArchived).toList();

  Conversation? getConversation(String friendId) => _conversations[friendId];

  int get totalUnread =>
      _conversations.values.fold(0, (sum, c) => sum + c.unreadCount);

  void sendMessage(String friendId, String friendName, String content,
      {ChatMessageType type = ChatMessageType.text,
      int? voiceDuration,
      String? replyToId}) {
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
      type: type,
      voiceDurationSeconds: voiceDuration,
      replyToId: replyToId,
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

  void addReaction(String friendId, String messageId, String emoji) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;

    final msgIndex = conversation.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    final message = conversation.messages[msgIndex];
    final reactions = List<MessageReaction>.from(message.reactions);

    final existingIndex =
        reactions.indexWhere((r) => r.userId == _currentUserId && r.emoji == emoji);
    if (existingIndex != -1) {
      reactions.removeAt(existingIndex);
    } else {
      reactions.add(MessageReaction(userId: _currentUserId, emoji: emoji));
    }

    conversation.messages[msgIndex] = message.copyWith(reactions: reactions);
    notifyListeners();
  }

  void toggleStarMessage(String friendId, String messageId) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;

    final msgIndex = conversation.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    conversation.messages[msgIndex] = conversation.messages[msgIndex]
        .copyWith(isStarred: !conversation.messages[msgIndex].isStarred);
    notifyListeners();
  }

  void deleteMessage(String friendId, String messageId) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;

    final msgIndex = conversation.messages.indexWhere((m) => m.id == messageId);
    if (msgIndex == -1) return;

    conversation.messages[msgIndex] = conversation.messages[msgIndex].copyWith(
      isDeleted: true,
      content: 'This message was deleted',
    );
    notifyListeners();
  }

  void togglePinConversation(String friendId) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;
    _conversations[friendId] = Conversation(
      friendId: conversation.friendId,
      friendName: conversation.friendName,
      messages: conversation.messages,
      isPinned: !conversation.isPinned,
      isMuted: conversation.isMuted,
      isArchived: conversation.isArchived,
    );
    notifyListeners();
  }

  void toggleMuteConversation(String friendId) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;
    _conversations[friendId] = Conversation(
      friendId: conversation.friendId,
      friendName: conversation.friendName,
      messages: conversation.messages,
      isPinned: conversation.isPinned,
      isMuted: !conversation.isMuted,
      isArchived: conversation.isArchived,
    );
    notifyListeners();
  }

  void archiveConversation(String friendId) {
    final conversation = _conversations[friendId];
    if (conversation == null) return;
    _conversations[friendId] = Conversation(
      friendId: conversation.friendId,
      friendName: conversation.friendName,
      messages: conversation.messages,
      isPinned: conversation.isPinned,
      isMuted: conversation.isMuted,
      isArchived: !conversation.isArchived,
    );
    notifyListeners();
  }

  List<Message> searchAllMessages(String query) {
    final results = <Message>[];
    for (final convo in _conversations.values) {
      results.addAll(convo.searchMessages(query));
    }
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return results;
  }

  List<String> getSmartReplies(String friendId) {
    final conversation = _conversations[friendId];
    if (conversation == null || conversation.messages.isEmpty) {
      return ['Hey! How are you?', 'What\'s up?', 'Long time no see!'];
    }

    final lastMsg = conversation.lastMessage;
    if (lastMsg == null) return [];

    final content = lastMsg.content.toLowerCase();

    if (content.contains('how are you') || content.contains('how\'s it going')) {
      return ['I\'m doing great, thanks!', 'Pretty good! You?', 'Living the dream!'];
    }
    if (content.contains('?')) {
      return ['Yes, definitely!', 'Let me think about it', 'Sounds good to me!'];
    }
    if (content.contains('thanks') || content.contains('thank you')) {
      return ['You\'re welcome!', 'Happy to help!', 'Anytime!'];
    }
    if (content.contains('hike') || content.contains('outdoor')) {
      return ['I\'m in! When?', 'What trail?', 'Let me check my schedule'];
    }
    if (content.contains('eat') || content.contains('food') || content.contains('recipe')) {
      return ['Sounds delicious!', 'Save me some!', 'We should cook together'];
    }
    if (content.contains('congrat') || content.contains('proud')) {
      return ['Thank you so much!', 'Means a lot!', 'Let\'s celebrate!'];
    }

    return ['Sounds great!', 'Tell me more!', 'That\'s awesome!'];
  }

  Map<String, dynamic> getConversationInsights(String friendId) {
    final conversation = _conversations[friendId];
    if (conversation == null) {
      return {'totalMessages': 0, 'sentiment': 'neutral'};
    }

    final messages = conversation.messages;
    final myMessages = messages.where((m) => m.senderId == _currentUserId).length;
    final theirMessages = messages.length - myMessages;

    String responsePattern;
    if (myMessages > theirMessages * 1.5) {
      responsePattern = 'You message more often';
    } else if (theirMessages > myMessages * 1.5) {
      responsePattern = 'They message more often';
    } else {
      responsePattern = 'Balanced conversation';
    }

    return {
      'totalMessages': messages.length,
      'myMessages': myMessages,
      'theirMessages': theirMessages,
      'responsePattern': responsePattern,
      'sentiment': 'positive',
      'topTopics': ['Plans', 'Activities', 'Catch-up'],
      'avgResponseTime': '15 min',
    };
  }
}
