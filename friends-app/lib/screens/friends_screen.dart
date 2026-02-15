import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/friend.dart';
import '../providers/friends_provider.dart';
import 'friend_detail_screen.dart';
import 'add_friend_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    List<Friend> friends = _searchQuery.isNotEmpty
        ? provider.search(_searchQuery)
        : _showFavoritesOnly
            ? provider.favorites
            : provider.friends;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              hintText: 'Search friends...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    ]
                  : null,
            ),
          ),
          Expanded(
            child: friends.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No friends match your search'
                              : 'No friends yet. Add some!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return _FriendTile(friend: friend);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFriendScreen()),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final Friend friend;

  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          friend.initials,
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(friend.name),
      subtitle: friend.phone.isNotEmpty ? Text(friend.phone) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (friend.isFavorite)
            const Icon(Icons.favorite, color: Colors.red, size: 18),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FriendDetailScreen(friendId: friend.id),
          ),
        );
      },
      onLongPress: () {
        context.read<FriendsProvider>().toggleFavorite(friend.id);
      },
    );
  }
}
