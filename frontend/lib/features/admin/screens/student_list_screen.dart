import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/student.dart';
import 'package:ashadeep/features/admin/screens/student_detail_screen.dart';
import 'package:ashadeep/core/services/student_service.dart';
import 'package:ashadeep/features/admin/screens/add_student_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> _allStudents = [];
  final Map<String, List<Student>> _studentsByClass = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Multi-select state
  bool _isSelectionMode = false;
  final Set<String> _selectedStudentIds = {};

  // Defined class order
  final List<String> _classOrder = [
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

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final students = await StudentService().getAllStudentsFlat();
    if (mounted) {
      setState(() {
        _allStudents = students;
        _groupStudents(students);
      });
    }
  }

  void _groupStudents(List<Student> students) {
    _studentsByClass.clear();
    for (var student in students) {
      if (!_studentsByClass.containsKey(student.className)) {
        _studentsByClass[student.className] = [];
      }
      _studentsByClass[student.className]!.add(student);
    }
    // Sort students within each class by name
    _studentsByClass.forEach((className, list) {
      list.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _groupStudents(_allStudents);
      } else {
        final filtered = _allStudents.where((student) {
          final nameMatch = student.name.toLowerCase().contains(
            query.toLowerCase(),
          );
          final admnMatch = student.admissionNumber.toLowerCase().contains(
            query.toLowerCase(),
          );
          return nameMatch || admnMatch;
        }).toList();
        _groupStudents(filtered);
      }
    });
  }

  // --- Multi-Select Logic ---

  void _toggleSelection(Student student) {
    setState(() {
      if (_selectedStudentIds.contains(student.id)) {
        _selectedStudentIds.remove(student.id);
        if (_selectedStudentIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedStudentIds.add(student.id);
      }
    });
  }

  void _startSelectionMode(Student student) {
    setState(() {
      _isSelectionMode = true;
      _selectedStudentIds.add(student.id);
    });
  }

  void _clearSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedStudentIds.clear();
    });
  }

  void _selectAllInClass(String className) {
    final students = _studentsByClass[className];
    if (students == null) return;
    setState(() {
      for (var s in students) {
        _selectedStudentIds.add(s.id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedStudentIds.isEmpty) return;

    final count = _selectedStudentIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Students'),
        content: Text(
          'Are you sure you want to permanently delete $count student${count > 1 ? 's' : ''}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final ids = _selectedStudentIds
        .map((id) => int.tryParse(id) ?? 0)
        .where((id) => id > 0)
        .toList();
    final deleted = await StudentService().deleteStudents(ids);

    if (!mounted) return;
    Navigator.pop(context); // dismiss loading

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted $deleted of $count student${count > 1 ? 's' : ''}.',
        ),
        backgroundColor: deleted == count ? Colors.green : Colors.orange,
      ),
    );

    _clearSelection();
    _loadStudents(); // Refresh
  }

  @override
  Widget build(BuildContext context) {
    // Get classes that actually have students and sort them according to _classOrder
    List<String> activeClasses = _studentsByClass.keys.toList();

    // Create a normalized class order for robust matching
    final normalizedOrder = _classOrder
        .map((e) => e.replaceAll('.', '').replaceAll(' ', '').toUpperCase())
        .toList();

    activeClasses.sort((a, b) {
      String normA = a.replaceAll('.', '').replaceAll(' ', '').toUpperCase();
      String normB = b.replaceAll('.', '').replaceAll(' ', '').toUpperCase();

      int indexA = normalizedOrder.indexOf(normA);
      int indexB = normalizedOrder.indexOf(normB);

      // Fallbacks for UKG -> KG mapping if they exist
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

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: _isSelectionMode ? _buildSelectionAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
          if (!_isSelectionMode)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryOf(context),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStudents,
                decoration: InputDecoration(
                  hintText: 'Search by Name or Admn No',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          Expanded(
            child: activeClasses.isEmpty
                ? const Center(child: Text('No students found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeClasses.length,
                    itemBuilder: (context, classIndex) {
                      final className = activeClasses[classIndex];
                      final studentsInClass = _studentsByClass[className]!;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: _searchQuery.isNotEmpty,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Class $className',
                                  style: AppTextStyles.heading2(context).copyWith(
                                    fontSize: 18,
                                    color: AppColors.primaryOf(context),
                                  ),
                                ),
                              ),
                              if (_isSelectionMode)
                                TextButton(
                                  onPressed: () => _selectAllInClass(className),
                                  child: const Text(
                                    'Select All',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text('${studentsInClass.length} students'),
                          children: studentsInClass.map((student) {
                            final isSelected = _selectedStudentIds.contains(
                              student.id,
                            );
                            return InkWell(
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  _startSelectionMode(student);
                                }
                              },
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(student);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StudentDetailScreen(student: student),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                color: isSelected
                                    ? AppColors.primaryOf(context).withValues(alpha: 0.08)
                                    : null,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: _isSelectionMode
                                      ? Checkbox(
                                          value: isSelected,
                                          activeColor: AppColors.primaryOf(context),
                                          onChanged: (_) =>
                                              _toggleSelection(student),
                                        )
                                      : CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppColors.primaryOf(context)
                                              .withValues(alpha: 0.1),
                                          child: Text(
                                            student.name.isNotEmpty
                                                ? student.name
                                                      .substring(0, 1)
                                                      .toUpperCase()
                                                : '?',
                                            style: AppTextStyles.heading2(context)
                                                .copyWith(
                                                  color: AppColors.primaryOf(context),
                                                  fontSize: 16,
                                                ),
                                          ),
                                        ),
                                  title: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        'Admn No: ${student.admissionNumber}',
                                      ),
                                      Text('Father: ${student.fatherName}'),
                                    ],
                                  ),
                                  trailing: _isSelectionMode
                                      ? null
                                      : Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppColors.textTertiaryOf(context),
                                        ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddStudentScreen(),
                  ),
                );

                if (result == true) {
                  _loadStudents();
                }
              },
              backgroundColor: AppColors.primaryOf(context),
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Add Student',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text('Students'),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: _clearSelection,
      ),
      title: Text(
        '${_selectedStudentIds.length} selected',
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColors.error,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_forever, color: Colors.white, size: 28),
          tooltip: 'Delete Selected',
          onPressed: _deleteSelected,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
