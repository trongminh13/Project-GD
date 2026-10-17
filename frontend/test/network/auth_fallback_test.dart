import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Demo & Offline Fallback Tests', () {
    late AuthService demoAuthService;
    late AuthService prodAuthService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      demoAuthService = AuthService(isDemoMode: true);
      prodAuthService = AuthService(isDemoMode: false);
    });

    test('TC-AUTH-FB-01: student01 logs in successfully in demo mode', () async {
      final res = await demoAuthService.login('student01', 'student123');

      expect(res['success'], isTrue);
      expect(res['user'], isA<User>());
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.student));
      expect(user.name, equals('Em Nguyễn Minh Anh'));
      expect(res['isDemo'], isTrue);

      final token = await demoAuthService.getToken();
      expect(token, isNotNull);
      expect(token, contains('mock_jwt_token_student01'));
    });

    test('TC-AUTH-FB-02: T001 teacher logs in successfully in demo mode', () async {
      final res = await demoAuthService.login('T001', 'teacher123');

      expect(res['success'], isTrue);
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.teacher));
      expect(user.name, equals('Cô Lê Thu Hà'));
      expect(res['isDemo'], isTrue);
    });

    test('TC-AUTH-FB-03: admin logs in successfully in demo mode', () async {
      final res = await demoAuthService.login('admin', 'admin123');

      expect(res['success'], isTrue);
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.admin));
      expect(res['isDemo'], isTrue);
    });

    test('TC-AUTH-FB-04: demo account with incorrect password returns clear sanitized error', () async {
      final res = await demoAuthService.login('student01', 'wrong_password_123');

      expect(res['success'], isFalse);
      expect(res['message'], contains('không chính xác'));
      expect(res['message'], isNot(contains('student123'))); // Không lộ mật khẩu
    });

    test('TC-AUTH-FB-05: parent OTP 123456 logs in successfully in demo mode', () async {
      final res = await demoAuthService.verifyOtpBackend('9910157611', '123456');

      expect(res['success'], isTrue);
      final user = res['user'] as User;
      expect(user.role, equals(UserRole.parent));
      expect(res['isDemo'], isTrue);
    });

    test('TC-AUTH-FB-06: Production mode NEVER falls back silently on network failure', () async {
      final res = await prodAuthService.login('student01', 'student123');

      expect(res['success'], isFalse);
      expect(res['message'], contains('Không thể kết nối đến máy chủ'));
      expect(res.containsKey('isDemo'), isFalse);
      expect(res.containsKey('user'), isFalse);
    });

    test('TC-CFG-URL-01: ApiConstants.baseUrl and isDemoMode evaluate cleanly', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.isDemoMode, isA<bool>());
    });
  });
}
