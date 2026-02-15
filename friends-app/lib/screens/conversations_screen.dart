import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  String _timeLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final conversations = context.watch<ChatProvider>().conversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No conversations yet',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Start chatting with a friend!',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final convo = conversations[index];
                final lastMsg = convo.lastMessage;
                final unread = convo.unreadCount;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      convo.friendName.isNotEmpty
                          ? convo.friendName[0]
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    convo.friendName,
                    style: TextStyle(
                      fontWeight:
                          unread > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: lastMsg != null
                      ? Text(
                          lastMsg.senderId == context.read<ChatProvider>().currentUserId
                              ? 'You: ${lastMsg.content}'
                              : lastMsg.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        )
                      : null,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (lastMsg != null)
                        Text(
                          _timeLabel(lastMsg.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (unread > 0) ...[
                        const SizedBox(height: 4),
                        Badge(
                          label: Text('$unread'),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          friendId: convo.friendId,
                          friendName: convo.friendName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
