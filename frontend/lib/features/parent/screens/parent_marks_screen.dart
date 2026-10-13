import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/marks_service.dart';

class ParentMarksScreen extends StatefulWidget {
  const ParentMarksScreen({super.key});

  @override
  State<ParentMarksScreen> createState() => _ParentMarksScreenState();
}

class _ParentMarksScreenState extends State<ParentMarksScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _marksData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _loadMarks();
  }

  Future<void> _loadMarks() async {
    // Dynamic fetching from backend service
    final data = await MarksService().getStudentMarks('student123');
    if (mounted) {
      setState(() {
        _marksData = data;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryOf(context)),
        ),
      );
    }

    // Calculate generic stats
    int totalObtained = 0;
    int totalMax = 0;
    for (var mark in _marksData) {
      totalObtained += (mark['marksObtained'] as num).toInt();
      totalMax += (mark['maxMarks'] as num).toInt();
    }
    double overallPercentage = totalMax == 0
        ? 0
        : (totalObtained / totalMax) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Results',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildPerformanceCard(context, overallPercentage, totalObtained, totalMax),
              const SizedBox(height: 20),
              _buildSubjectWiseMarks(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(
    BuildContext context,
    double percentage,
    int obtained,
    int max,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardGradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];
    final shadowColor = isDark
        ? const Color(0xFF5C6BC0).withValues(alpha: 0.4)
        : const Color(0xFF1A237E).withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Overall Performance",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Total: $obtained / $max",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectWiseMarks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subject-wise Score",
            style: AppTextStyles.heading2(context),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _marksData.length,
            itemBuilder: (context, index) {
              final item = _marksData[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOf(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primaryOf(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['subject'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            item['examName'],
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${item['marksObtained']} / ${item['maxMarks']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryOf(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Grade: ${item['grade']}",
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
