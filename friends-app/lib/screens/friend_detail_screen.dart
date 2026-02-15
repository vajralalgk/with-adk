import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/friends_provider.dart';
import '../providers/events_provider.dart';
import 'chat_screen.dart';

class FriendDetailScreen extends StatelessWidget {
  final String friendId;

  const FriendDetailScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context) {
    final friend = context.watch<FriendsProvider>().getFriendById(friendId);
    final events = context.watch<EventsProvider>().getEventsForFriend(friendId);
    final colorScheme = Theme.of(context).colorScheme;

    if (friend == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Friend not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(friend.name),
        actions: [
          IconButton(
            icon: Icon(
              friend.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: friend.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              context.read<FriendsProvider>().toggleFavorite(friend.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Remove Friend'),
                  content: Text('Remove ${friend.name} from your friends?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<FriendsProvider>().removeFriend(friend.id);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                friend.initials,
                style: TextStyle(
                  fontSize: 32,
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              friend.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionChip(
                icon: Icons.chat,
                label: 'Message',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        friendId: friend.id,
                        friendName: friend.name,
                      ),
                    ),
                  );
                },
              ),
              _ActionChip(
                icon: Icons.phone,
                label: 'Call',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${friend.name}...')),
                  );
                },
              ),
              _ActionChip(
                icon: Icons.email,
                label: 'Email',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening email to ${friend.name}...')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Contact info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Info',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Divider(),
                  if (friend.phone.isNotEmpty)
                    _InfoRow(icon: Icons.phone, label: 'Phone', value: friend.phone),
                  if (friend.email.isNotEmpty)
                    _InfoRow(icon: Icons.email, label: 'Email', value: friend.email),
                  if (friend.birthday != null)
                    _InfoRow(
                        icon: Icons.cake,
                        label: 'Birthday',
                        value: DateFormat.yMMMd().format(friend.birthday!)),
                ],
              ),
            ),
          ),
          if (friend.notes != null && friend.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    Text(friend.notes!),
                  ],
                ),
              ),
            ),
          ],
          if (events.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Events',
                        style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    ...events.map((e) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            e.isCompleted
                                ? Icons.check_circle
                                : Icons.event,
                            color: e.isCompleted ? Colors.green : null,
                          ),
                          title: Text(e.title),
                          subtitle:
                              Text(DateFormat.yMMMd().format(e.date)),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}
