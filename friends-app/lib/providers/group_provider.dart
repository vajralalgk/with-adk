import 'package:flutter/foundation.dart';
import '../models/group.dart';

class GroupProvider extends ChangeNotifier {
  static const String _currentUserId = 'me';

  final List<Group> _groups = [
    Group(
      id: 'g1',
      name: 'Weekend Hikers',
      description: 'Planning hikes and outdoor adventures',
      members: [
        GroupMember(friendId: 'me', name: 'You', role: GroupRole.owner),
        GroupMember(friendId: '1', name: 'Alice Johnson', role: GroupRole.admin),
        GroupMember(friendId: '4', name: 'David Lee'),
        GroupMember(friendId: '5', name: 'Emma Wilson'),
      ],
      messages: [
        GroupMessage(
          id: 'gm1',
          senderId: '1',
          senderName: 'Alice Johnson',
          content: 'Who\'s up for Mount Rainier this Saturday?',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        GroupMessage(
          id: 'gm2',
          senderId: 'me',
          senderName: 'You',
          content: 'Count me in! What time?',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        GroupMessage(
          id: 'gm3',
          senderId: '4',
          senderName: 'David Lee',
          content: 'I can bring my camping gear if we want to stay overnight',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    Group(
      id: 'g2',
      name: 'Study Group',
      description: 'Grad school study sessions and resource sharing',
      members: [
        GroupMember(friendId: 'me', name: 'You'),
        GroupMember(friendId: '3', name: 'Carol Davis', role: GroupRole.owner),
        GroupMember(friendId: '2', name: 'Bob Smith'),
      ],
      messages: [
        GroupMessage(
          id: 'gm4',
          senderId: '3',
          senderName: 'Carol Davis',
          content: 'Library at 3pm tomorrow? We need to review chapter 7.',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        GroupMessage(
          id: 'gm5',
          senderId: '2',
          senderName: 'Bob Smith',
          content: 'I\'ll bring snacks!',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    ),
    Group(
      id: 'g3',
      name: 'Music Jam',
      description: 'Jamming sessions and music sharing',
      members: [
        GroupMember(friendId: 'me', name: 'You'),
        GroupMember(friendId: '4', name: 'David Lee', role: GroupRole.owner),
        GroupMember(friendId: '1', name: 'Alice Johnson'),
        GroupMember(friendId: '5', name: 'Emma Wilson'),
        GroupMember(friendId: '2', name: 'Bob Smith'),
      ],
      messages: [
        GroupMessage(
          id: 'gm6',
          senderId: '4',
          senderName: 'David Lee',
          content: 'New song idea - check the shared board!',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
  ];

  String get currentUserId => _currentUserId;

  List<Group> get groups => List.unmodifiable(_groups);

  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void createGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void sendMessage(String groupId, String content) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;

    final group = _groups[index];
    final messages = List<GroupMessage>.from(group.messages);
    messages.add(GroupMessage(
      id: 'gm_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId,
      senderName: 'You',
      content: content,
    ));

    _groups[index] = group.copyWith(messages: messages);
    notifyListeners();
  }

  void addMember(String groupId, GroupMember member) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;

    final group = _groups[index];
    final members = List<GroupMember>.from(group.members);
    members.add(member);
    _groups[index] = group.copyWith(members: members);
    notifyListeners();
  }

  void removeMember(String groupId, String friendId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;

    final group = _groups[index];
    final members = group.members.where((m) => m.friendId != friendId).toList();
    _groups[index] = group.copyWith(members: members);
    notifyListeners();
  }

  void toggleMute(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;
    _groups[index] = _groups[index].copyWith(isMuted: !_groups[index].isMuted);
    notifyListeners();
  }

  void togglePin(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;
    _groups[index] = _groups[index].copyWith(isPinned: !_groups[index].isPinned);
    notifyListeners();
  }

  void leaveGroup(String groupId) {
    _groups.removeWhere((g) => g.id == groupId);
    notifyListeners();
  }

  void updateGroup(String groupId, {String? name, String? description}) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index == -1) return;
    _groups[index] = _groups[index].copyWith(
      name: name,
      description: description,
    );
    notifyListeners();
  }
}
