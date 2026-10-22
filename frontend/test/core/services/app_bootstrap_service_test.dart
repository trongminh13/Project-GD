import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/core/services/app_bootstrap_service.dart';
import 'package:ashadeep/screens/login_screen.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/features/admin/screens/dashboard_screen.dart';
import 'package:ashadeep/features/auth/screens/force_change_password_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Chưa đăng nhập -> trả về LoginScreen', () async {
    final screen = await AppBootstrapService.resolveInitialScreen();
    expect(screen, isA<LoginScreen>());
  });

  test('Session thiếu roles -> xoá và trả về LoginScreen', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 1,
        'username': 'student1',
        'roles': [],
      }),
      'auth_token': 'mock_jwt_student',
    });

    final screen = await AppBootstrapService.resolveInitialScreen();
    expect(screen, isA<LoginScreen>());

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_data'), isNull);
  });

  test('User phải đổi mật khẩu -> trả về ForceChangePasswordScreen', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 1,
        'username': 'student1',
        'roles': ['ROLE_STUDENT'],
        'token': 'mock_jwt_student',
        'mustChangePassword': true,
      }),
    });

    final screen = await AppBootstrapService.resolveInitialScreen();
    expect(screen, isA<ForceChangePasswordScreen>());
  });

  test('Session mock_jwt student hợp lệ -> trả về StudentDashboardScreen', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 1,
        'username': 'student1',
        'roles': ['ROLE_STUDENT'],
        'token': 'mock_jwt_student',
        'mustChangePassword': false,
      }),
    });

    final screen = await AppBootstrapService.resolveInitialScreen();
    expect(screen, isA<StudentDashboardScreen>());
  });

  test('Session mock_jwt admin hợp lệ -> trả về DashboardScreen', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({
        'id': 2,
        'username': 'admin1',
        'roles': ['ROLE_ADMIN'],
        'token': 'mock_jwt_admin',
        'mustChangePassword': false,
      }),
    });

    final screen = await AppBootstrapService.resolveInitialScreen();
    expect(screen, isA<DashboardScreen>());
  });
}
