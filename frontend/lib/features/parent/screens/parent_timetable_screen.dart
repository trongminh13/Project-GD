import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';

class ParentTimetableScreen extends StatefulWidget {
  const ParentTimetableScreen({super.key});

  @override
  State<ParentTimetableScreen> createState() => _ParentTimetableScreenState();
}

class _ParentTimetableScreenState extends State<ParentTimetableScreen>
    with SingleTickerProviderStateMixin {
  String _selectedDay = "Monday";
  final List<String> _days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  // Mock Data: Timetable for the whole week
  final Map<String, List<Map<String, String>>> _weeklyTimetable = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Class Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final isSelected = day == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryOf(context)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondaryOf(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildTimetableList(_selectedDay),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableList(String day) {
    final timetable = _weeklyTimetable[day] ?? [];

    if (timetable.isEmpty) {
      return Center(child: Text("No classes for $day"));
    }

    return ListView.separated(
      key: ValueKey(day),
      padding: const EdgeInsets.all(20),
      itemCount: timetable.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final slot = timetable[index];
        final isBreak =
            slot['subject'] == 'Lunch Break' || slot['subject'] == 'Dispersal';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isBreak
                ? AppColors.warning.withOpacity(0.08)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBreak
                  ? AppColors.warning.withOpacity(0.3)
                  : AppColors.borderOf(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isBreak
                      ? AppColors.warning.withOpacity(0.15)
                      : AppColors.primaryOf(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  slot['time']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isBreak
                        ? AppColors.warning
                        : AppColors.primaryOf(context),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot['subject']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    if (!isBreak) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppColors.textTertiaryOf(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            slot['teacher']!,
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isBreak)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltOf(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.class_outlined,
                    size: 20,
                    color: AppColors.textTertiaryOf(context),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
