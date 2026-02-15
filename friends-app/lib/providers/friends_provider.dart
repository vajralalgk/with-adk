import 'package:flutter/foundation.dart';
import '../models/friend.dart';

class FriendsProvider extends ChangeNotifier {
  final List<Friend> _friends = [
    Friend(
      id: '1',
      name: 'Alice Johnson',
      phone: '+1 555-0101',
      email: 'alice@example.com',
      birthday: DateTime(1995, 3, 15),
      notes: 'Met at college. Loves hiking.',
      isFavorite: true,
    ),
    Friend(
      id: '2',
      name: 'Bob Smith',
      phone: '+1 555-0102',
      email: 'bob@example.com',
      birthday: DateTime(1993, 7, 22),
      notes: 'Work colleague. Great at cooking.',
    ),
    Friend(
      id: '3',
      name: 'Carol Davis',
      phone: '+1 555-0103',
      email: 'carol@example.com',
      birthday: DateTime(1997, 11, 8),
      isFavorite: true,
    ),
    Friend(
      id: '4',
      name: 'David Lee',
      phone: '+1 555-0104',
      email: 'david@example.com',
      birthday: DateTime(1994, 1, 30),
      notes: 'Neighbor. Plays guitar.',
    ),
    Friend(
      id: '5',
      name: 'Emma Wilson',
      phone: '+1 555-0105',
      email: 'emma@example.com',
      birthday: DateTime(1996, 9, 12),
    ),
  ];

  List<Friend> get friends => List.unmodifiable(_friends);

  List<Friend> get favorites => _friends.where((f) => f.isFavorite).toList();

  Friend? getFriendById(String id) {
    try {
      return _friends.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  void addFriend(Friend friend) {
    _friends.add(friend);
    notifyListeners();
  }

  void updateFriend(Friend friend) {
    final index = _friends.indexWhere((f) => f.id == friend.id);
    if (index != -1) {
      _friends[index] = friend;
      notifyListeners();
    }
  }

  void removeFriend(String id) {
    _friends.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = _friends.indexWhere((f) => f.id == id);
    if (index != -1) {
      _friends[index] = _friends[index].copyWith(
        isFavorite: !_friends[index].isFavorite,
      );
      notifyListeners();
    }
  }

  List<Friend> search(String query) {
    final lower = query.toLowerCase();
    return _friends
        .where((f) =>
            f.name.toLowerCase().contains(lower) ||
            f.email.toLowerCase().contains(lower) ||
            f.phone.contains(query))
        .toList();
  }
}
