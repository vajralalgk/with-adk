import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;

  const ChatScreen({
    super.key,
    required this.friendId,
    required this.friendName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _replyToId;
  String? _replyToContent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markAsRead(widget.friendId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(
          widget.friendId,
          widget.friendName,
          text,
          replyToId: _replyToId,
        );
    _controller.clear();
    setState(() {
      _replyToId = null;
      _replyToContent = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showReactionPicker(String messageId) {
    final emojis = ['❤️', '😂', '😮', '😢', '👍', '🔥'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emojis
                .map((emoji) => GestureDetector(
                      onTap: () {
                        context.read<ChatProvider>().addReaction(
                              widget.friendId,
                              messageId,
                              emoji,
                            );
                        Navigator.pop(ctx);
                      },
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  void _showMessageOptions(Message message) {
    final chatProvider = context.read<ChatProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _replyToId = message.id;
                  _replyToContent = message.content;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(ctx);
                _showReactionPicker(message.id);
              },
            ),
            ListTile(
              leading: Icon(
                message.isStarred ? Icons.star : Icons.star_border,
              ),
              title: Text(message.isStarred ? 'Unstar' : 'Star'),
              onTap: () {
                chatProvider.toggleStarMessage(widget.friendId, message.id);
                Navigator.pop(ctx);
              },
            ),
            if (message.senderId == chatProvider.currentUserId)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  chatProvider.deleteMessage(widget.friendId, message.id);
                  Navigator.pop(ctx);
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final conversation = chatProvider.getConversation(widget.friendId);
    final messages = conversation?.messages ?? [];
    final smartReplies = chatProvider.getSmartReplies(widget.friendId);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                widget.friendName.isNotEmpty ? widget.friendName[0] : '?',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.friendName, style: const TextStyle(fontSize: 16)),
                  Text('Online',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green.shade400,
                      )),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () => _showInsights(context),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              switch (val) {
                case 'pin':
                  chatProvider.togglePinConversation(widget.friendId);
                  break;
                case 'mute':
                  chatProvider.toggleMuteConversation(widget.friendId);
                  break;
                case 'archive':
                  chatProvider.archiveConversation(widget.friendId);
                  Navigator.pop(context);
                  break;
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'pin',
                child: Text(conversation?.isPinned == true ? 'Unpin' : 'Pin'),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Text(conversation?.isMuted == true ? 'Unmute' : 'Mute'),
              ),
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe =
                          message.senderId == chatProvider.currentUserId;

                      return GestureDetector(
                        onLongPress: () => _showMessageOptions(message),
                        onDoubleTap: () => _showReactionPicker(message.id),
                        child: Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: message.isDeleted
                                      ? Colors.grey.shade300
                                      : isMe
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe
                                        ? const Radius.circular(16)
                                        : const Radius.circular(4),
                                    bottomRight: isMe
                                        ? const Radius.circular(4)
                                        : const Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (message.replyToId != null)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        margin: const EdgeInsets.only(bottom: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Replying to a message',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                            color: isMe
                                                ? colorScheme.onPrimary
                                                    .withOpacity(0.7)
                                                : colorScheme.onSurface
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    if (message.type == ChatMessageType.voice)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.mic,
                                              size: 16,
                                              color: isMe
                                                  ? colorScheme.onPrimary
                                                  : colorScheme.onSurface),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${message.voiceDurationSeconds ?? 0}s',
                                            style: TextStyle(
                                              color: isMe
                                                  ? colorScheme.onPrimary
                                                  : colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: message.isDeleted
                                            ? Colors.grey
                                            : isMe
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface,
                                        fontStyle: message.isDeleted
                                            ? FontStyle.italic
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (message.isStarred)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Icon(Icons.star,
                                                size: 12,
                                                color: isMe
                                                    ? colorScheme.onPrimary
                                                        .withOpacity(0.7)
                                                    : Colors.amber),
                                          ),
                                        Text(
                                          '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isMe
                                                ? colorScheme.onPrimary
                                                    .withOpacity(0.7)
                                                : colorScheme.onSurface
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            message.isRead
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 14,
                                            color: message.isRead
                                                ? Colors.blue
                                                : colorScheme.onPrimary
                                                    .withOpacity(0.5),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (message.hasReactions)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: colorScheme.outline
                                            .withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: message.reactionCounts.entries
                                        .map((e) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              child: Text(
                                                '${e.key} ${e.value}',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                )
                              else
                                const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Smart replies
          if (smartReplies.isNotEmpty &&
              messages.isNotEmpty &&
              messages.last.senderId != chatProvider.currentUserId)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: smartReplies
                    .map((reply) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(reply, style: const TextStyle(fontSize: 12)),
                            onPressed: () {
                              _controller.text = reply;
                              _sendMessage();
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        ))
                    .toList(),
              ),
            ),
          // Reply indicator
          if (_replyToContent != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Container(width: 3, height: 30, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _replyToContent!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() {
                      _replyToId = null;
                      _replyToContent = null;
                    }),
                  ),
                ],
              ),
            ),
          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      context.read<ChatProvider>().sendMessage(
                            widget.friendId,
                            widget.friendName,
                            'Voice message',
                            type: ChatMessageType.voice,
                            voiceDuration: 5,
                          );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsights(BuildContext context) {
    final insights =
        context.read<ChatProvider>().getConversationInsights(widget.friendId);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights),
                  const SizedBox(width: 8),
                  Text('Conversation Insights',
                      style: Theme.of(ctx).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 20),
              _InsightRow(icon: Icons.message, label: 'Total Messages', value: '${insights['totalMessages']}'),
              _InsightRow(icon: Icons.send, label: 'You Sent', value: '${insights['myMessages']}'),
              _InsightRow(icon: Icons.inbox, label: 'They Sent', value: '${insights['theirMessages']}'),
              _InsightRow(icon: Icons.balance, label: 'Pattern', value: '${insights['responsePattern']}'),
              _InsightRow(icon: Icons.speed, label: 'Avg Response', value: '${insights['avgResponseTime']}'),
              _InsightRow(icon: Icons.mood, label: 'Sentiment', value: '${insights['sentiment']}'),
              const SizedBox(height: 12),
              Text('Top Topics', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (insights['topTopics'] as List<String>)
                    .map((t) => Chip(label: Text(t)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
