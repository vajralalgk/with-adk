import 'package:flutter/foundation.dart';
import '../models/memory.dart';

class MemoryProvider extends ChangeNotifier {
  final List<Memory> _memories = [
    Memory(
      id: 'mem1',
      friendId: '1',
      friendName: 'Alice Johnson',
      type: MemoryType.event,
      title: 'First Hike Together',
      description: 'Our first hike at Mount Rainier. Alice almost got lost but we had the best time!',
      date: DateTime.now().subtract(const Duration(days: 180)),
      location: 'Mount Rainier',
      tags: ['hiking', 'outdoors', 'adventure'],
      isFavorite: true,
    ),
    Memory(
      id: 'mem2',
      friendId: '2',
      friendName: 'Bob Smith',
      type: MemoryType.chat,
      title: 'The Recipe Challenge',
      description: 'When Bob challenged me to a cook-off and we both failed spectacularly',
      date: DateTime.now().subtract(const Duration(days: 90)),
      tags: ['cooking', 'fun', 'food'],
    ),
    Memory(
      id: 'mem3',
      friendId: '3',
      friendName: 'Carol Davis',
      type: MemoryType.milestone,
      title: 'Carol\'s Grad School Acceptance',
      description: 'The day we found out Carol got accepted! We went out to celebrate.',
      date: DateTime.now().subtract(const Duration(days: 3)),
      location: 'Downtown Restaurant',
      tags: ['celebration', 'achievement'],
      isFavorite: true,
    ),
    Memory(
      id: 'mem4',
      friendId: '4',
      friendName: 'David Lee',
      type: MemoryType.event,
      title: 'Backyard Jam Session',
      description: 'David taught me three chords and we played until midnight',
      date: DateTime.now().subtract(const Duration(days: 45)),
      location: 'David\'s backyard',
      tags: ['music', 'guitar'],
    ),
    Memory(
      id: 'mem5',
      friendId: '5',
      friendName: 'Emma Wilson',
      type: MemoryType.photo,
      title: 'Beach Sunset Photo',
      description: 'The most incredible sunset we\'ve ever witnessed together',
      date: DateTime.now().subtract(const Duration(days: 14)),
      location: 'Malibu Beach',
      tags: ['sunset', 'beach', 'nature'],
      isFavorite: true,
    ),
    Memory(
      id: 'mem6',
      friendId: '1',
      friendName: 'Alice Johnson',
      type: MemoryType.note,
      title: 'Alice\'s Birthday Surprise',
      description: 'Successfully planned a surprise birthday party with 20 people!',
      date: DateTime.now().subtract(const Duration(days: 270)),
      tags: ['birthday', 'surprise', 'party'],
    ),
  ];

  List<Memory> get memories => List.unmodifiable(_memories)
    ..sort((a, b) => b.date.compareTo(a.date));

  List<Memory> get favoriteMemories =>
      _memories.where((m) => m.isFavorite).toList();

  List<Memory> getMemoriesForFriend(String friendId) =>
      _memories.where((m) => m.friendId == friendId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  SharedTimeline getTimeline(String friendId, String friendName) {
    return SharedTimeline(
      friendId: friendId,
      friendName: friendName,
      memories: getMemoriesForFriend(friendId),
      friendshipStartDate: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  void addMemory(Memory memory) {
    _memories.add(memory);
    notifyListeners();
  }

  void removeMemory(String memoryId) {
    _memories.removeWhere((m) => m.id == memoryId);
    notifyListeners();
  }

  void toggleFavorite(String memoryId) {
    final index = _memories.indexWhere((m) => m.id == memoryId);
    if (index == -1) return;
    _memories[index] = _memories[index].copyWith(
      isFavorite: !_memories[index].isFavorite,
    );
    notifyListeners();
  }

  List<Memory> search(String query) {
    final lower = query.toLowerCase();
    return _memories
        .where((m) =>
            m.title.toLowerCase().contains(lower) ||
            (m.description?.toLowerCase().contains(lower) ?? false) ||
            m.tags.any((t) => t.toLowerCase().contains(lower)) ||
            m.friendName.toLowerCase().contains(lower))
        .toList();
  }

  List<Memory> getMemoriesByTag(String tag) =>
      _memories.where((m) => m.tags.contains(tag)).toList();

  List<Memory> get todayInHistory {
    final now = DateTime.now();
    return _memories
        .where((m) =>
            m.date.month == now.month &&
            m.date.day == now.day &&
            m.date.year != now.year)
        .toList();
  }
}
