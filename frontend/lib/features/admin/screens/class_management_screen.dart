import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/school_class.dart';
import 'package:ashadeep/core/services/school_class_service.dart';
import 'package:ashadeep/core/services/teacher_service.dart';
import 'package:ashadeep/models/teacher.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final _classService = ClassService();
  final _teacherService = TeacherService();
  List<SchoolClass> _classes = [];
  List<Teacher> _cachedTeachers = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _loadTeachers();
  }

  void _loadClasses() {
    setState(() {
      _classes = _classService.getAllClasses();
    });
  }

  Future<void> _loadTeachers() async {
    final teachers = await _teacherService.getAllTeachersFlat();
    if (mounted) {
      setState(() {
        _cachedTeachers = teachers;
      });
    }
  }

  void _showAddClassDialog() {
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Class'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Class (e.g., 5)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (gradeController.text.isNotEmpty) {
                final newClass = SchoolClass(
                  id: 'new',
                  grade: gradeController.text,
                  subjects: [],
                );
                _classService.addClass(newClass);
                _loadClasses();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Class Added!')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAssignTeacherDialog(SchoolClass schoolClass) {
    Teacher? selectedTeacher;
    final teachers = _cachedTeachers;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Assign Teacher to Class ${schoolClass.grade}'),
            content: DropdownButton<Teacher>(
              hint: const Text('Select Class Teacher'),
              value: selectedTeacher,
              isExpanded: true,
              items: teachers.map((teacher) {
                return DropdownMenuItem(
                  value: teacher,
                  child: Text(teacher.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedTeacher = val);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedTeacher != null) {
                    _classService.updateClassTeacher(
                      schoolClass.id,
                      selectedTeacher!.id,
                      selectedTeacher!.name,
                    );
                    _loadClasses();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${selectedTeacher!.name} assigned to Class ${schoolClass.grade}!',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSubjectManagementDialog(SchoolClass schoolClass) {
    final teachers = _cachedTeachers;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Subjects for Class ${schoolClass.grade}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: schoolClass.subjects.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final subject = schoolClass.subjects[index];
                  final assignedTeacherName =
                      schoolClass.subjectTeachers[subject] ?? 'Not Assigned';

                  return ListTile(
                    title: Text(
                      subject,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      assignedTeacherName,
                      style: TextStyle(
                        color: assignedTeacherName == 'Not Assigned'
                            ? AppColors.error
                            : AppColors.success,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Teacher? selectedSubjectTeacher;

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Assign $subject Teacher'),
                            content: DropdownButtonFormField<Teacher>(
                              items: teachers
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                selectedSubjectTeacher = val;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Select Teacher',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (selectedSubjectTeacher != null) {
                                    _classService.updateSubjectTeacher(
                                      schoolClass.id,
                                      subject,
                                      selectedSubjectTeacher!.name,
                                    );
                                    Navigator.pop(
                                      context,
                                    ); // Close assign dialog
                                    setState(() {}); // Refresh list
                                    _loadClasses(); // Refresh main screen
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text(
          'Manage Classes',
        ),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _classes.length,
        itemBuilder: (context, index) {
          final schoolClass = _classes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AppColors.secondaryOf(context).withOpacity(0.1),
                child: Text(
                  schoolClass.grade,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryOf(context),
                  ),
                ),
              ),
              title: Text(
                'Class ${schoolClass.grade}',
                style: AppTextStyles.heading2(context).copyWith(fontSize: 18),
              ),
              subtitle: Text(
                'Class Teacher: ${schoolClass.classTeacherName}',
                style: TextStyle(
                  color: schoolClass.classTeacherId.isEmpty
                      ? AppColors.error
                      : AppColors.textSecondaryOf(context),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.book, color: Colors.blueAccent),
                    onPressed: () => _showSubjectManagementDialog(schoolClass),
                    tooltip: 'Manage Subjects',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_add_alt,
                      color: AppColors.primaryOf(context),
                    ),
                    onPressed: () => _showAssignTeacherDialog(schoolClass),
                    tooltip: 'Assign Class Teacher',
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClassDialog,
        backgroundColor: AppColors.primaryOf(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Class', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
