import 'package:flutter/foundation.dart';
import '../models/event.dart';

class EventsProvider extends ChangeNotifier {
  final List<FriendEvent> _events = [
    FriendEvent(
      id: 'e1',
      friendId: '1',
      friendName: 'Alice Johnson',
      type: EventType.meetup,
      title: 'Weekend hike',
      description: 'Hiking at Mount Rainier trailhead',
      date: DateTime.now().add(const Duration(days: 2)),
    ),
    FriendEvent(
      id: 'e2',
      friendId: '3',
      friendName: 'Carol Davis',
      type: EventType.birthday,
      title: 'Carol\'s Birthday',
      description: 'Don\'t forget to get a gift!',
      date: DateTime(DateTime.now().year, 11, 8),
    ),
    FriendEvent(
      id: 'e3',
      friendId: '2',
      friendName: 'Bob Smith',
      type: EventType.call,
      title: 'Catch up call with Bob',
      date: DateTime.now().add(const Duration(days: 5)),
    ),
    FriendEvent(
      id: 'e4',
      friendId: '4',
      friendName: 'David Lee',
      type: EventType.meetup,
      title: 'Guitar jam session',
      description: 'Bring acoustic guitar',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isCompleted: true,
    ),
    FriendEvent(
      id: 'e5',
      friendId: '5',
      friendName: 'Emma Wilson',
      type: EventType.custom,
      title: 'Return borrowed book',
      description: 'The Great Gatsby',
      date: DateTime.now().add(const Duration(days: 7)),
    ),
  ];

  List<FriendEvent> get events => List.unmodifiable(_events);

  List<FriendEvent> get upcomingEvents => _events
      .where((e) => !e.isCompleted && e.date.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<FriendEvent> get pastEvents => _events
      .where((e) => e.isCompleted || e.date.isBefore(DateTime.now()))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<FriendEvent> getEventsForFriend(String friendId) =>
      _events.where((e) => e.friendId == friendId).toList();

  void addEvent(FriendEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(FriendEvent event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }

  void toggleComplete(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index] = _events[index].copyWith(
        isCompleted: !_events[index].isCompleted,
      );
      notifyListeners();
    }
  }

  void removeEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }
}
