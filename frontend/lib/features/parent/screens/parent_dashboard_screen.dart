import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/config/feature_flags.dart';
import 'package:ashadeep/core/widgets/fade_in_list_item.dart';
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/screens/profile_screen.dart';
import 'package:ashadeep/core/network/api_client.dart';
import 'package:ashadeep/features/parent/screens/parent_ward_details_screen.dart';
import 'package:ashadeep/core/widgets/demo_mode_banner.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<dynamic> _wards = [];
  bool _isLoadingWards = true;

  @override
  void initState() {
    super.initState();
    _fetchParentProfile();
    _fetchMyWards();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchParentProfile() async {
    // Left empty for now. We used to fetch a generic Parent Name, but now
    // the UI is driven entirely by the fetched Wards List instead!
  }

  Future<void> _fetchMyWards() async {
    if (ApiConstants.isDemoMode || FeatureFlags.useDemoFallback) {
      if (mounted) {
        setState(() {
          _wards = [
            {
              'id': 1,
              'name': 'Nguyễn Minh Anh',
              'grade': '10',
              'section': 'A1',
              'className': 'Lớp 10A1',
              'rollNo': 'HS001',
              'classTeacher': 'Cô Lê Thu Hà',
            }
          ];
          _isLoadingWards = false;
        });
      }
      return;
    }

    try {
      final data = await ApiClient().get('/students/my-wards');
      debugPrint('[WARD DEBUG] Parsed response: $data');
      if (data is List) {
        if (mounted) {
          setState(() {
            _wards = data;
            _isLoadingWards = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingWards = false);
      }
    } catch (e) {
      debugPrint('[WARD DEBUG] Exception: $e');
      if (mounted) setState(() => _isLoadingWards = false);
    }
  }

  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        final now = DateTime.now();
        final maxDuration = const Duration(seconds: 2);
        final isWarning =
            _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > maxDuration;

        if (isWarning) {
          _lastPressedAt = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          const platform = MethodChannel('com.school.backend/appRetain');
          try {
            platform.invokeMethod('sendToBackground');
          } catch (e) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 80.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: headerGradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
              title: const Text(
                'Parent Portal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        )
                        .then(
                          (_) => _fetchParentProfile(),
                        ); // refresh when coming back
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SliverToBoxAdapter(
              child: DemoModeBanner(),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInListItem(
                          index: 0,
                          child: Text(
                            "My Wards",
                            style: AppTextStyles.heading2(context),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _isLoadingWards
                            ? const Center(child: CircularProgressIndicator())
                            : _wards.isEmpty
                            ? const Center(child: Text("No Wards Found"))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _wards.length,
                                itemBuilder: (context, index) {
                                  final ward = _wards[index];
                                  final classStr = ward['schoolClass'] != null
                                      ? "Class ${ward['schoolClass']['grade']}"
                                      : "Class N/A";
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: FadeInListItem(
                                      index: index + 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ParentWardDetailsScreen(
                                                    ward: ward,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: _buildWardProfileCard(
                                          context,
                                          ward['name'] ?? 'Unknown',
                                          classStr,
                                          ward['admissionNumber'] ?? 'N/A',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardProfileCard(
    BuildContext context,
    String name,
    String className,
    String admNo,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardGradientColors = isDark
        ? [const Color(0xFF5C6BC0), const Color(0xFF3949AB)]
        : [const Color(0xFF1A237E), const Color(0xFF0D1454)];
    final shadowColor = isDark
        ? const Color(0xFF5C6BC0).withValues(alpha: 0.4)
        : const Color(0xFF1A237E).withValues(alpha: 0.4);

    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryOf(context).withValues(alpha: 0.15),
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.primaryOf(context),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Student Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Adm No: $admNo | $className",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
