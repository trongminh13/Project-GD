import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/student.dart';
import 'package:ashadeep/models/school_class.dart';
import 'package:ashadeep/core/services/student_service.dart';
import 'package:ashadeep/core/services/school_class_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _admissionNoController = TextEditingController();

  // Dynamic Data
  List<SchoolClass> _allSchoolClasses = [];
  List<String> _availableGrades = [];
  // List<String> _availableSections = []; // Removed

  // Selected Values
  String? _selectedGrade;
  // String? _selectedSection; // Removed
  String _selectedGender = 'Male';

  // Options
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() {
    _allSchoolClasses = ClassService().getAllClasses();
    _availableGrades = _allSchoolClasses.map((e) => e.grade).toSet().toList();
    // Sort grades using priority order: Nursery, LKG, UKG, 1-12
    const classOrder = [
      'Nursery',
      'LKG',
      'KG',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ];
    final normalizedOrder = classOrder
        .map((e) => e.replaceAll('.', '').replaceAll(' ', '').toUpperCase())
        .toList();

    _availableGrades.sort((a, b) {
      String normA = a.replaceAll('.', '').replaceAll(' ', '').toUpperCase();
      String normB = b.replaceAll('.', '').replaceAll(' ', '').toUpperCase();

      int indexA = normalizedOrder.indexOf(normA);
      int indexB = normalizedOrder.indexOf(normB);

      if (indexA == -1 && normA == 'UKG') {
        indexA = normalizedOrder.indexOf('KG');
      }
      if (indexB == -1 && normB == 'UKG') {
        indexB = normalizedOrder.indexOf('KG');
      }

      if (indexA == -1) indexA = 999;
      if (indexB == -1) indexB = 999;

      if (indexA == indexB) return a.compareTo(b);
      return indexA.compareTo(indexB);
    });

    if (_availableGrades.isNotEmpty) {
      _selectedGrade = _availableGrades.first;
      // _updateSections(); // Removed
    }
  }

  // void _updateSections() { // Removed
  //   setState(() {
  //     _availableSections =
  //         _allSchoolClasses
  //             .where((c) => c.grade == _selectedGrade)
  //             .map((c) => c.section)
  //             .toSet()
  //             .toList()
  //           ..sort();

  //     if (_availableSections.isNotEmpty) {
  //       _selectedSection = _availableSections.first;
  //     } else {
  //       _selectedSection = null;
  //     }
  //   });
  // }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGrade == null) {
        // Simplified check
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select Class'),
          ), // Updated message
        );
        return;
      }

      final newStudent = Student(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // Simple ID generation
        name: _nameController.text,
        className: _selectedGrade!,
        fatherName: _fatherNameController.text,
        motherName: _motherNameController.text,
        aadhaar: 'PENDING', // Default for now
        gender: _selectedGender,
        photoUrl: _selectedGender == 'Male'
            ? 'assets/student_boy.png'
            : 'assets/student_girl.png',
        admissionNumber: _admissionNumberController.text,
        mobileNumber: _mobileController.text,
      );

      StudentService().addStudent(newStudent);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student Added Successfully!')),
      );

      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _admissionNumberController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _mobileController.dispose();
    _admissionNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text(
          'Add New Student',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryOf(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 60,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ensure all details are correct before saving.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionCard(
                      context: context,
                      title: 'Student Details',
                      icon: Icons.school,
                      children: [
                        _buildTextField(
                          context,
                          'Full Name',
                          _nameController,
                          Icons.person,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                context,
                                'Admn No',
                                _admissionNumberController,
                                Icons.numbers,
                                isNumber: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                context,
                                'Class',
                                _availableGrades,
                                _selectedGrade,
                                (val) {
                                  setState(() {
                                    _selectedGrade = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          context,
                          'Gender',
                          _genders,
                          _selectedGender,
                          (val) => setState(() => _selectedGender = val!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      context: context,
                      title: 'Guardian Details',
                      icon: Icons.family_restroom,
                      children: [
                        _buildTextField(
                          context,
                          'Father\'s Name',
                          _fatherNameController,
                          Icons.male,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context,
                          'Mother\'s Name',
                          _motherNameController,
                          Icons.female,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context,
                          'Mobile Number',
                          _mobileController,
                          Icons.phone,
                          isNumber: true,
                          maxLength: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOf(context),
                        foregroundColor:
                            Colors.white, // Ensures Text Color is White
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.primaryOf(context).withOpacity(0.5),
                      ),
                      child: const Text(
                        'SAVE STUDENT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOf(context), size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.heading2(context).copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: AppColors.primaryOf(context).withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryOf(context), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryOf(context), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryOf(context)),
    );
  }
}
