import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Demo & Offline Fallback Tests', () {
    late AuthService authService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authService = AuthService();
    });

    test('TC-AUTH-FB-01: student01 logs in successfully via demo fallback', () async {
      final res = await authService.login('student01', 'student123');

      expect(res['success'], isTrue);
      expect(res['user'], isA<User>());
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.student));
      expect(user.name, equals('Em Nguyễn Minh Anh'));
      expect(res['isDemo'], isTrue);

      final token = await authService.getToken();
      expect(token, isNotNull);
      expect(token, contains('mock_jwt_token_student01'));
    });

    test('TC-AUTH-FB-02: T001 teacher logs in successfully via demo fallback', () async {
      final res = await authService.login('T001', 'teacher123');

      expect(res['success'], isTrue);
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.teacher));
      expect(user.name, equals('Cô Lê Thu Hà'));
      expect(res['isDemo'], isTrue);
    });

    test('TC-AUTH-FB-03: admin logs in successfully via demo fallback', () async {
      final res = await authService.login('admin', 'admin123');

      expect(res['success'], isTrue);
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.admin));
      expect(res['isDemo'], isTrue);
    });

    test('TC-AUTH-FB-04: demo account with incorrect password returns clear error', () async {
      final res = await authService.login('student01', 'wrong_password_123');

      expect(res['success'], isFalse);
      expect(res['message'], contains('Mật khẩu không chính xác'));
    });

    test('TC-AUTH-FB-05: parent OTP 123456 logs in successfully via demo fallback', () async {
      final res = await authService.verifyOtpBackend('9910157611', '123456');

      expect(res['success'], isTrue);
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.parent));
      expect(res['isDemo'], isTrue);
    });

    test('TC-CFG-URL-01: ApiConstants.baseUrl and isDemoMode evaluate cleanly', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.isDemoMode, isA<bool>());
    });
  });
}
