class Student {
  final String id;
  final String name;
  final String className;
  final String fatherName;
  final String motherName;
  final String aadhaar;
  final String gender;
  final String photoUrl;

  final String admissionNumber;
  final String mobileNumber;
  final String address;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.fatherName,
    required this.motherName,
    required this.aadhaar,
    required this.gender,
    required this.photoUrl,
    this.admissionNumber = '',
    this.mobileNumber = '0',
    this.address = '',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    // Backend returns nested schoolClass object: {grade: "5", section: "A"}
    final schoolClass = json['schoolClass'];
    String className = '';
    if (schoolClass != null && schoolClass is Map) {
      className = schoolClass['grade']?.toString() ?? '';
    } else {
      className = json['className']?.toString() ?? '';
    }

    // Backend returns nested parent object: {name: "...", phone: "..."}
    final parent = json['parent'];
    String fatherName = '';
    String mobileNumber = '';
    if (parent != null && parent is Map) {
      fatherName = parent['name']?.toString() ?? '';
      mobileNumber = parent['phone']?.toString() ?? '';
    } else {
      fatherName = json['fatherName']?.toString() ?? '';
      mobileNumber = json['mobileNumber']?.toString() ?? '';
    }

    return Student(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      className: className,
      fatherName: fatherName,
      motherName: json['motherName'] ?? '',
      aadhaar: json['aadhaar'] ?? '',
      gender: json['gender'] ?? 'Male',
      photoUrl: json['photoUrl'] ?? 'assets/student_boy.png',
      admissionNumber: json['admissionNumber'] ?? '',
      mobileNumber: mobileNumber,
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'fatherName': fatherName,
      'motherName': motherName,
      'aadhaar': aadhaar,
      'gender': gender,
      'photoUrl': photoUrl,
      'admissionNumber': admissionNumber,
      'mobileNumber': mobileNumber,
      'address': address,
    };
  }
}
