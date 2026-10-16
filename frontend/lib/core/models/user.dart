enum UserRole {
  admin,
  teacher,
  parent,
  student,
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final String? token;
  final bool mustChangePassword;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.photoUrl,
    this.token,
    this.mustChangePassword = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['username'] ?? 'User',
      role: _parseRole(json['roles'] != null && (json['roles'] as List).isNotEmpty
          ? json['roles'][0]
          : ''),
      token: json['token'],
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }

  static UserRole _parseRole(String role) {
    final normalized = role.toUpperCase();
    if (normalized == 'ROLE_ADMIN' || normalized == 'ADMIN') {
      return UserRole.admin;
    } else if (normalized == 'ROLE_TEACHER' || normalized == 'TEACHER') {
      return UserRole.teacher;
    } else if (normalized == 'ROLE_PARENT' || normalized == 'PARENT') {
      return UserRole.parent;
    } else if (normalized == 'ROLE_STUDENT' || normalized == 'STUDENT') {
      return UserRole.student;
    }
    return UserRole.parent; // Fallback
  }
}
