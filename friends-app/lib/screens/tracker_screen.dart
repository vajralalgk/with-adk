import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../providers/events_provider.dart';
import '../providers/friends_provider.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();
    final upcoming = eventsProvider.upcomingEvents;
    final past = eventsProvider.pastEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (upcoming.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Upcoming',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ),
            ...upcoming.map((e) => _EventCard(event: e)),
          ],
          if (past.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text('Past',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ),
            ...past.map((e) => _EventCard(event: e)),
          ],
          if (upcoming.isEmpty && past.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Icon(Icons.event_note_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No events tracked yet',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    EventType selectedType = EventType.meetup;
    String? selectedFriendId;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

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
                  Text('Add Event',
                      style: Theme.of(ctx).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Friend', border: OutlineInputBorder()),
                    items: friends
                        .map((f) => DropdownMenuItem(
                            value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedFriendId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: 'Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EventType>(
                    decoration: const InputDecoration(
                        labelText: 'Type', border: OutlineInputBorder()),
                    value: selectedType,
                    items: EventType.values
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.name[0].toUpperCase() +
                                  t.name.substring(1)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMd().format(selectedDate)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (selectedFriendId != null &&
                          titleController.text.trim().isNotEmpty) {
                        final friend = friends
                            .firstWhere((f) => f.id == selectedFriendId);
                        context.read<EventsProvider>().addEvent(FriendEvent(
                              id: 'evt_${DateTime.now().millisecondsSinceEpoch}',
                              friendId: selectedFriendId!,
                              friendName: friend.name,
                              type: selectedType,
                              title: titleController.text.trim(),
                              description: descController.text.trim().isNotEmpty
                                  ? descController.text.trim()
                                  : null,
                              date: selectedDate,
                            ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add Event'),
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

class _EventCard extends StatelessWidget {
  final FriendEvent event;

  const _EventCard({required this.event});

  IconData _iconForType(EventType type) {
    switch (type) {
      case EventType.meetup:
        return Icons.groups;
      case EventType.birthday:
        return Icons.cake;
      case EventType.call:
        return Icons.phone;
      case EventType.message:
        return Icons.message;
      case EventType.custom:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.isCompleted
              ? Colors.grey.shade300
              : colorScheme.primaryContainer,
          child: Icon(
            _iconForType(event.type),
            color: event.isCompleted
                ? Colors.grey
                : colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            decoration:
                event.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.friendName),
            Text(
              DateFormat.yMMMd().format(event.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                event.isCompleted
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: event.isCompleted ? Colors.green : null,
              ),
              onPressed: () {
                context.read<EventsProvider>().toggleComplete(event.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                context.read<EventsProvider>().removeEvent(event.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
