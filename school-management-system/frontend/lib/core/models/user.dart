enum UserRole {
  admin,
  teacher,
  parent, // Future use
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.photoUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['username'] ?? 'User', // Backend sends 'username'
      role: _parseRole(json['roles'][0]), // Backend sends list of roles
      token: json['token'],
    );
  }

  static UserRole _parseRole(String role) {
    // Normalize string just in case
    final normalized = role.toUpperCase();
    if (normalized == 'ROLE_ADMIN' || normalized == 'ADMIN') {
      return UserRole.admin;
    } else if (normalized == 'ROLE_TEACHER' || normalized == 'TEACHER') {
      return UserRole.teacher;
    } else if (normalized == 'ROLE_PARENT' || normalized == 'PARENT') {
      return UserRole.parent;
    }
    return UserRole.parent; // Fallback
  }
}
