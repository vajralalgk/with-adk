import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/memory.dart';
import '../providers/memory_provider.dart';
import '../providers/friends_provider.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final memoryProvider = context.watch<MemoryProvider>();
    final todayMemories = memoryProvider.todayInHistory;
    final allMemories = _searchQuery.isNotEmpty
        ? memoryProvider.search(_searchQuery)
        : memoryProvider.memories;
    final favorites = memoryProvider.favoriteMemories;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Search
          SearchBar(
            hintText: 'Search memories...',
            leading: const Icon(Icons.search),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
            trailing: _searchQuery.isNotEmpty
                ? [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  ]
                : null,
          ),
          const SizedBox(height: 16),
          // Today in History
          if (todayMemories.isNotEmpty) ...[
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          'On This Day',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...todayMemories.map((m) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Text(m.typeIcon, style: const TextStyle(fontSize: 20)),
                          title: Text(m.title),
                          subtitle: Text('${m.friendName} - ${m.date.year}'),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Favorites
          if (favorites.isNotEmpty && _searchQuery.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Favorite Memories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
            ),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: favorites
                    .map((m) => _MemoryHighlightCard(memory: m))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // All Memories
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Search Results (${allMemories.length})'
                  : 'All Memories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (allMemories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.photo_album_outlined,
                        size: 64,
                        color: colorScheme.onSurface.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'No memories match your search'
                          : 'No memories yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ...allMemories.map((m) => _MemoryCard(memory: m)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemoryDialog(context),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController();
    final tagsController = TextEditingController();
    MemoryType selectedType = MemoryType.note;
    String? selectedFriendId;
    DateTime selectedDate = DateTime.now();

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
                  Text('Add Memory',
                      style: Theme.of(ctx).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Friend', border: OutlineInputBorder()),
                    items: friends
                        .map((f) => DropdownMenuItem(
                            value: f.id, child: Text(f.name)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedFriendId = val),
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
                        labelText: 'Description',
                        border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<MemoryType>(
                          decoration: const InputDecoration(
                              labelText: 'Type',
                              border: OutlineInputBorder()),
                          value: selectedType,
                          items: MemoryType.values
                              .map((t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t.name[0].toUpperCase() +
                                        t.name.substring(1)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedType = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormat.yMMMd().format(selectedDate)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
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
                        final tags = tagsController.text.trim().isNotEmpty
                            ? tagsController.text
                                .trim()
                                .split(',')
                                .map((t) => t.trim())
                                .toList()
                            : <String>[];
                        context.read<MemoryProvider>().addMemory(Memory(
                              id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
                              friendId: selectedFriendId!,
                              friendName: friend.name,
                              type: selectedType,
                              title: titleController.text.trim(),
                              description: descController.text.trim().isNotEmpty
                                  ? descController.text.trim()
                                  : null,
                              date: selectedDate,
                              location:
                                  locationController.text.trim().isNotEmpty
                                      ? locationController.text.trim()
                                      : null,
                              tags: tags,
                            ));
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save Memory'),
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

class _MemoryHighlightCard extends StatelessWidget {
  final Memory memory;

  const _MemoryHighlightCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(right: 12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 200,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.secondary.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memory.typeIcon,
                      style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  Text(
                    memory.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${memory.friendName} - ${DateFormat.yMMMd().format(memory.date)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.favorite,
                color: Colors.red.shade300,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final Memory memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(memory.typeIcon, style: const TextStyle(fontSize: 24)),
        title: Text(memory.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(memory.friendName),
            Row(
              children: [
                Text(
                  DateFormat.yMMMd().format(memory.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (memory.location != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                  Text(
                    memory.location!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            if (memory.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: memory.tags
                      .map((t) => Chip(
                            label: Text(t, style: const TextStyle(fontSize: 10)),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            memory.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: memory.isFavorite ? Colors.red : null,
            size: 20,
          ),
          onPressed: () {
            context.read<MemoryProvider>().toggleFavorite(memory.id);
          },
        ),
      ),
    );
  }
}
