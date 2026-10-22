import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/features/admin/screens/dashboard_screen.dart';
import 'package:ashadeep/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_dashboard_screen.dart';
import 'package:ashadeep/features/auth/screens/force_change_password_screen.dart';

/// Dịch vụ khởi động song song của ứng dụng (Parallel Bootstrap Service).
/// Thực hiện đọc cấu hình lưu trữ, kiểm tra phiên đăng nhập và định tuyến màn hình
/// ban đầu mà không làm chặn giao diện hoạt ảnh mở đầu.
class AppBootstrapService {
  AppBootstrapService._();

  /// Xác định màn hình đích đầu tiên dựa trên phiên làm việc của người dùng.
  static Future<Widget> resolveInitialScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final Map<String, dynamic> userData = jsonDecode(userDataString);

        // Kiểm tra danh sách quyền (roles) hợp lệ
        if (userData['roles'] == null || (userData['roles'] as List).isEmpty) {
          await prefs.remove('user_data');
          return const LoginScreen();
        }

        final token = await AuthService().getToken();
        if (token == null) {
          await prefs.remove('user_data');
          return const LoginScreen();
        }

        // Bỏ qua ping mạng nếu là phiên demo hoặc chế độ giả lập offline
        if (token.startsWith('mock_jwt_') || ApiConstants.isDemoMode) {
          final user = User.fromJson(userData);
          return _getScreenForUser(user);
        }

        // Kiểm tra token nhanh với timeout 1.5s
        final isValid = await _validateToken(token);
        if (!isValid) {
          await AuthService().logout();
          return const LoginScreen();
        }

        final user = User.fromJson(userData);
        return _getScreenForUser(user);
      }
    } catch (e) {
      debugPrint('AppBootstrapService: error during bootstrap: $e');
    }

    return const LoginScreen();
  }

  static Widget _getScreenForUser(User user) {
    if (user.mustChangePassword) {
      return ForceChangePasswordScreen(user: user);
    }

    switch (user.role) {
      case UserRole.student:
        return const StudentDashboardScreen();
      case UserRole.admin:
        return const DashboardScreen();
      case UserRole.teacher:
        return TeacherDashboardScreen(
          teacherId: user.id,
          teacherName: user.name,
        );
      case UserRole.parent:
        return const ParentDashboardScreen();
    }
  }

  static Future<bool> _validateToken(String token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/profile');
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(milliseconds: 1500));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
