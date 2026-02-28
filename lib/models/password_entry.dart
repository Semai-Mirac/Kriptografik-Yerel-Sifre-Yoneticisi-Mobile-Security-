class PasswordEntry {
  const PasswordEntry({
    this.id,
    required this.title,
    required this.username,
    required this.category,
    required this.encryptedPassword,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final String username;
  final String category;
  final String encryptedPassword;
  final int createdAt;

  PasswordEntry copyWith({
    int? id,
    String? title,
    String? username,
    String? category,
    String? encryptedPassword,
    int? createdAt,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      category: category ?? this.category,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'category': category,
      'encrypted_password': encryptedPassword,
      'created_at': createdAt,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    final idRaw = map['id'];
    final createdAtRaw = map['created_at'] ?? map['createdAt'];

    return PasswordEntry(
      id: idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? ''),
      title: map['title'] as String,
      username: map['username'] as String,
      category: (map['category'] as String?) ?? 'Kişisel',
      encryptedPassword:
          (map['encrypted_password'] ?? map['encryptedPassword']) as String,
      createdAt: createdAtRaw is int
          ? createdAtRaw
          : int.tryParse(createdAtRaw?.toString() ?? '') ??
              DateTime.now().millisecondsSinceEpoch,
    );
  }
}
