import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/teacher.dart';
import 'package:ashadeep/features/admin/screens/teacher_detail_screen.dart';
import 'package:ashadeep/core/services/teacher_service.dart';
import 'package:ashadeep/features/admin/screens/add_teacher_screen.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  List<Teacher> _allTeachers = [];
  List<Teacher> _filteredTeachers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final teachers = await TeacherService().getAllTeachersFlat();
    if (mounted) {
      setState(() {
        _allTeachers = teachers;
        _filteredTeachers = _allTeachers;
      });
    }
  }

  void _filterTeachers(String query) {
    setState(() {
      _filteredTeachers = _allTeachers
          .where((teacher) =>
              teacher.name.toLowerCase().contains(query.toLowerCase()) ||
              teacher.subject.toLowerCase().contains(query.toLowerCase()) ||
              teacher.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Teachers Directory'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryOf(context),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTeachers,
              decoration: InputDecoration(
                hintText: 'Search by Name, ID or Subject',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredTeachers.length,
              itemBuilder: (context, index) {
                final teacher = _filteredTeachers[index];
                final isPresent = teacher.isPresent;

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: isPresent ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                      child: Text(
                        teacher.name.isNotEmpty ? teacher.name.substring(0, 1) : 'T',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPresent ? AppColors.success : AppColors.error,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(teacher.name, style: AppTextStyles.heading2(context).copyWith(fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher.subject, style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold)),
                        Text('ID: ${teacher.id} | Exp: ${teacher.experience}'),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiaryOf(context)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TeacherDetailScreen(teacherId: teacher.id, name: teacher.name)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTeacherScreen()),
          );

          if (result == true) {
            _loadTeachers();
          }
        },
        backgroundColor: AppColors.primaryOf(context),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Teacher', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
