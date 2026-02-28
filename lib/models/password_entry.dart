class PasswordEntry {
  const PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
  });

  final String id;
  final String title;
  final String username;
  final String encryptedPassword;

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? username,
    String? encryptedPassword,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'encryptedPassword': encryptedPassword,
    };
  }

  factory PasswordEntry.fromMap(Map<String, dynamic> map) {
    return PasswordEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      username: map['username'] as String,
      encryptedPassword: map['encryptedPassword'] as String,
    );
  }
}
