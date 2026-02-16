import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../providers/group_provider.dart';
import '../providers/friends_provider.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: groups.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No groups yet',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Create a group to chat with multiple friends!',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final lastMsg = group.lastMessage;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      group.name.isNotEmpty ? group.name[0] : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(group.name)),
                      if (group.isMuted)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.volume_off,
                              size: 16, color: Colors.grey.shade400),
                        ),
                      if (group.isPinned)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.push_pin,
                              size: 16, color: Colors.grey.shade400),
                        ),
                    ],
                  ),
                  subtitle: lastMsg != null
                      ? Text(
                          '${lastMsg.senderName}: ${lastMsg.content}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text('${group.memberCount} members'),
                  trailing: lastMsg != null
                      ? Text(
                          _timeLabel(lastMsg.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupChatScreen(groupId: group.id),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.group_add),
      ),
    );
  }

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

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final selectedFriends = <String>{};
    final friends = context.read<FriendsProvider>().friends;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Group',
                      style: Theme.of(ctx).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Add Members',
                      style: Theme.of(ctx).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: ListView(
                      children: friends
                          .map((f) => CheckboxListTile(
                                title: Text(f.name),
                                value: selectedFriends.contains(f.id),
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      selectedFriends.add(f.id);
                                    } else {
                                      selectedFriends.remove(f.id);
                                    }
                                  });
                                },
                                dense: true,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty &&
                          selectedFriends.isNotEmpty) {
                        final members = <GroupMember>[
                          GroupMember(
                              friendId: 'me',
                              name: 'You',
                              role: GroupRole.owner),
                          ...selectedFriends.map((id) {
                            final friend = friends.firstWhere((f) => f.id == id);
                            return GroupMember(friendId: id, name: friend.name);
                          }),
                        ];

                        context.read<GroupProvider>().createGroup(Group(
                              id: 'g_${DateTime.now().millisecondsSinceEpoch}',
                              name: nameController.text.trim(),
                              description: descController.text.trim().isNotEmpty
                                  ? descController.text.trim()
                                  : null,
                              members: members,
                            ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Create Group'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
