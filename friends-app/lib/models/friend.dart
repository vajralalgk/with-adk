class Friend {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final DateTime? birthday;
  final String? notes;
  final DateTime lastInteraction;
  final bool isFavorite;

  Friend({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.avatarUrl,
    this.birthday,
    this.notes,
    DateTime? lastInteraction,
    this.isFavorite = false,
  }) : lastInteraction = lastInteraction ?? DateTime.now();

  Friend copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    DateTime? birthday,
    String? notes,
    DateTime? lastInteraction,
    bool? isFavorite,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthday: birthday ?? this.birthday,
      notes: notes ?? this.notes,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
