class Teacher {
  final String id;
  final String name;
  final String subject;
  final String email;
  final String phone;
  final String qualification;
  final String experience;
  final String photoUrl;
  bool isPresent;

  Teacher({
    required this.id,
    required this.name,
    required this.subject,
    this.email = '',
    this.phone = '',
    this.qualification = '',
    this.experience = '',
    this.photoUrl = 'assets/teacher_placeholder.png',
    this.isPresent = true,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      subject: json['subjectSpecialization'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      qualification: json['qualification'] ?? '',
      experience: '',
      photoUrl: json['photoUrl'] ?? 'assets/teacher_placeholder.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjectSpecialization': subject,
      'email': email,
      'phone': phone,
      'qualification': qualification,
      'photoUrl': photoUrl,
    };
  }
}
