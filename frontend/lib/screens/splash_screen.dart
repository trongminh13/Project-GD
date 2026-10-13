import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/features/admin/screens/dashboard_screen.dart';
import 'package:ashadeep/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userDataString);

        // Validate that roles exist and are parseable
        if (userData['roles'] == null || (userData['roles'] as List).isEmpty) {
          await prefs.remove('user_data');
          _navigateToLogin();
          return;
        }

        // Validate token is still valid by checking with backend
        final token = await AuthService().getToken();
        if (token == null) {
          await prefs.remove('user_data');
          _navigateToLogin();
          return;
        }

        // Quick token validation - try to fetch profile
        final isValid = await _validateToken(token);
        if (!isValid) {
          await AuthService().logout();
          if (!mounted) return;
          _navigateToLogin();
          return;
        }

        final user = User.fromJson(userData);
        if (!mounted) return;

        if (user.role == UserRole.admin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
          return;
        } else if (user.role == UserRole.teacher) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TeacherDashboardScreen(
                teacherId: user.id,
                teacherName: user.name,
              ),
            ),
          );
          return;
        } else if (user.role == UserRole.parent) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ParentDashboardScreen(),
            ),
          );
          return;
        }
      } catch (e) {
        await prefs.remove('user_data');
      }
    }

    if (!mounted) return;
    _navigateToLogin();
  }

  Future<bool> _validateToken(String token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/profile');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.splashBackground,
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'AshaDeep',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.splashText,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
