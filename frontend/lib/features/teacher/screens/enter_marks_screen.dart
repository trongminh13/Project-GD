import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/models/assessment.dart';
import 'package:ashadeep/models/student.dart';

import 'package:ashadeep/core/services/student_service.dart';
import 'package:ashadeep/core/services/marks_service.dart';

class EnterMarksScreen extends StatefulWidget {
  final Assessment assessment;
  const EnterMarksScreen({super.key, required this.assessment});

  @override
  State<EnterMarksScreen> createState() => _EnterMarksScreenState();
}

class _EnterMarksScreenState extends State<EnterMarksScreen> {
  // Use StudentService to fetch students dynamically
  List<Student> _filteredStudents = [];
  final Map<String, TextEditingController> _marksControllers = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final cName = widget.assessment.className;

    final fetchedStudents = await StudentService().getStudentsByClass(cName);
    if (mounted) {
      setState(() {
        _filteredStudents = fetchedStudents;
        for (var s in _filteredStudents) {
          _marksControllers[s.id] = TextEditingController();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _marksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.assessment.title} Marks',
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class: ${widget.assessment.className}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Max Marks: ${widget.assessment.maxMarks}',
                  style: AppTextStyles.heading2(context).copyWith(
                    color: AppColors.primaryOf(context),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryOf(context).withValues(alpha: 0.1),
                          child: Text(
                            student.admissionNumber,
                            style: TextStyle(
                              color: AppColors.primaryOf(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            student.admissionNumber,
                            style: AppTextStyles.body(context).copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _marksControllers[student.id],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '/${widget.assessment.maxMarks}',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final mark = int.tryParse(value);
                                if (mark != null &&
                                    mark > widget.assessment.maxMarks) {
                                  return 'Err';
                                }
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOf(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.assessment.isLocked
                    ? null
                    : () async {
                        // Validate all inputs
                        bool isValid = true;
                        for (var controller in _marksControllers.values) {
                          final text = controller.text;
                          if (text.isNotEmpty) {
                            final val = int.tryParse(text);
                            if (val == null ||
                                val > widget.assessment.maxMarks) {
                              isValid = false;
                              break;
                            }
                          }
                        }

                        if (isValid) {
                          // Extract marks map
                          Map<String, int> marksData = {};
                          for (var entry in _marksControllers.entries) {
                            if (entry.value.text.isNotEmpty) {
                              marksData[entry.key] = int.parse(
                                entry.value.text,
                              );
                            }
                          }

                          // Use MarksService to upload to backend
                          final success = await MarksService()
                              .uploadClassMarks(
                                widget.assessment.className,
                                widget.assessment.id,
                                marksData,
                                subject: widget.assessment.subject,
                                maxMarks: widget.assessment.maxMarks,
                              );
                                if (!context.mounted) return;
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Marks Saved Successfully!',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to save marks.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please check marks. Cannot exceed Max Marks.',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Save Marks',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
