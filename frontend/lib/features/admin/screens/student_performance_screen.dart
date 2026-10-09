import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';

class StudentPerformanceScreen extends StatefulWidget {
  const StudentPerformanceScreen({super.key});

  @override
  State<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends State<StudentPerformanceScreen> {
  String _selectedClass = '10-A';

  // Mock Data for Different Classes
  final Map<String, Map<String, dynamic>> _classData = {
    '10-A': {
      'subjects': {'Mathematics': 0.85, 'Science': 0.72, 'English': 0.90, 'History': 0.65},
      'stats': {'toppers': '5', 'average': '78%', 'failed': '2'},
      'leaderboard': [
        {'name': 'Aarav Kumar', 'score': '98%', 'rank': 1},
        {'name': 'Neha Gupta', 'score': '96%', 'rank': 2},
        {'name': 'Vikram Singh', 'score': '94%', 'rank': 3},
      ]
    },
    '10-B': {
      'subjects': {'Mathematics': 0.75, 'Science': 0.80, 'English': 0.85, 'History': 0.70},
      'stats': {'toppers': '3', 'average': '72%', 'failed': '4'},
      'leaderboard': [
        {'name': 'Rohan Das', 'score': '95%', 'rank': 1},
        {'name': 'Sita Verma', 'score': '92%', 'rank': 2},
        {'name': 'Amit Roy', 'score': '89%', 'rank': 3},
      ]
    },
    '9-A': {
      'subjects': {'Mathematics': 0.60, 'Science': 0.65, 'English': 0.88, 'History': 0.80},
      'stats': {'toppers': '2', 'average': '68%', 'failed': '8'},
      'leaderboard': [
        {'name': 'Karan Johar', 'score': '91%', 'rank': 1},
        {'name': 'Arjun Rampal', 'score': '88%', 'rank': 2},
        {'name': 'Priya Warrier', 'score': '85%', 'rank': 3},
      ]
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = _classData[_selectedClass]!;
    final subjects = data['subjects'] as Map<String, double>;
    final stats = data['stats'] as Map<String, String>;
    final leaderboard = data['leaderboard'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Performance Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClass,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryOf(context)),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryOf(context)),
                  items: _classData.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text('Class $value Overview'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedClass = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Charts
            _buildPerformanceCard(
              context: context,
              title: 'Subject-wise Performance',
              child: Column(
                children: subjects.entries.map((entry) {
                  return _buildBarChart(
                    context: context,
                    label: entry.key,
                    value: entry.value,
                    color: _getColorForSubject(entry.key)
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            _buildPerformanceCard(
              context: context,
              title: 'Recent Exam: Mid-Term 2025',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircleStat('Toppers', stats['toppers']!, AppColors.warning),
                  _buildCircleStat('Average', stats['average']!, AppColors.primaryOf(context)),
                  _buildCircleStat('Failed', stats['failed']!, AppColors.error),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Leaderboard
            Text('Student Leaderboard', style: AppTextStyles.heading2(context)),
            const SizedBox(height: 12),
            ...leaderboard.map((student) => _buildStudentRankItem(
              context,
              student['rank'],
              student['name'],
              student['score']
            )),
          ],
        ),
      ),
    );
  }

  Color _getColorForSubject(String subject) {
    switch (subject) {
      case 'Mathematics': return AppColors.primary;
      case 'Science': return AppColors.success;
      case 'English': return AppColors.warning;
      case 'History': return AppColors.secondary;
      default: return AppColors.lightTextTertiary;
    }
  }

  Widget _buildPerformanceCard({required BuildContext context, required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBarChart({required BuildContext context, required String label, required double value, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
            child: Stack(
              children: [
                Container(height: 10, decoration: BoxDecoration(color: AppColors.surfaceAltOf(context), borderRadius: BorderRadius.circular(5))),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5))),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${(value * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildCircleStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
          child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textTertiaryOf(context))),
      ],
    );
  }

  Widget _buildStudentRankItem(BuildContext context, int rank, String name, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1 ? AppColors.warning : (rank == 2 ? AppColors.lightSilver : AppColors.secondary),
              shape: BoxShape.circle,
            ),
            child: Text('#$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          CircleAvatar(backgroundColor: AppColors.primaryOf(context), radius: 20, child: const Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(score, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16)),
        ],
      ),
    );
  }
}
