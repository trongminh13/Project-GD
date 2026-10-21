import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/core/network/api_timeout_policy.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/config/feature_flags.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final http.Client? _httpClient;
  final bool? _isDemoModeOverride;
  String? _verificationId;

  AuthService({http.Client? client, bool? isDemoMode})
      : _httpClient = client,
        _isDemoModeOverride = isDemoMode;

  bool get isDemoMode => _isDemoModeOverride ?? ApiConstants.isDemoMode;
  http.Client get _client => _httpClient ?? http.Client();

  firebase_auth.FirebaseAuth? get _firebaseAuth {
    try {
      return firebase_auth.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  // --- Backend Login (Admin/Teacher/Student) ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Nếu môi trường demo (chưa cấu hình domain backend thật)
    if (isDemoMode) {
      return _tryDemoLogin(username, password);
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/auth/signin');
    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(ApiTimeoutPolicy.mutation.duration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        if (user.token != null) {
          try {
            await _storage.write(key: 'jwt_token', value: user.token);
          } catch (_) {}
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

        return {
          'success': true,
          'user': user,
          'mustChangePassword': user.mustChangePassword,
        };
      } else if (response.statusCode == 423) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'locked': true,
          'message': data['message'] ??
              'Tài khoản đã bị tạm khóa do nhập sai mật khẩu 5 lần. Vui lòng thử lại sau 15 phút.',
        };
      } else {
        // Trong môi trường debug/demo fallback, nếu tài khoản demo chuẩn chưa kịp nạp vào DB
        final allowFallback = isDemoMode || (_isDemoModeOverride != false && FeatureFlags.useDemoFallback);
        if (allowFallback) {
          final u = username.trim().toLowerCase();
          if (u == 'student01' || u == 'student02' || u == 'student03' ||
              u == 't001' || u == 'admin' || u == '9910157611') {
            final demoRes = await _tryDemoLogin(username, password);
            if (demoRes['success'] == true) {
              return demoRes;
            }
          }
        }
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Tài khoản hoặc mật khẩu không chính xác.',
        };
      }
    } catch (e) {
      // TUYỆT ĐỐI KHÔNG SILENT FALLBACK TRÊN BẢN PRODUCTION:
      // Kích hoạt demo login khi có cờ isDemoMode hoặc khi _isDemoModeOverride != false và FeatureFlags.useDemoFallback
      final allowFallback = isDemoMode || (_isDemoModeOverride != false && FeatureFlags.useDemoFallback);
      if (allowFallback) {
        return _tryDemoLogin(username, password);
      }
      return {
        'success': false,
        'message': 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng.',
      };
    }
  }

  /// Cơ chế xác thực dự phòng cho môi trường Demo và Offline
  Future<Map<String, dynamic>> _tryDemoLogin(
    String username,
    String password,
  ) async {
    final u = username.trim().toLowerCase();

    Map<String, dynamic>? demoUserData;
    String expectedPass = '';

    if (u == 'student01' || u == 'hocsinh.demo' || u == 'hocsinh1.demo') {
      expectedPass = 'student123';
      demoUserData = {
        'id': '1',
        'username': 'Em Nguyễn Minh Anh',
        'roles': ['ROLE_STUDENT'],
        'token': 'mock_jwt_token_student01',
        'mustChangePassword': false,
        'grade': '1',
        'section': 'A',
        'className': 'Lớp 1A',
        'classTeacher': 'Cô Lê Thu Hà',
        'schoolName': 'Trường Tiểu học Đại Việt',
        'educationLevel': 'PRIMARY',
        'educationLevelName': 'Tiểu học',
      };
    } else if (u == 'student02' || u == 'hocsinh2.demo') {
      expectedPass = 'student123';
      demoUserData = {
        'id': '2',
        'username': 'Em Trần Bảo Nam',
        'roles': ['ROLE_STUDENT'],
        'token': 'mock_jwt_token_student02',
        'mustChangePassword': false,
        'grade': '6',
        'section': 'A',
        'className': 'Lớp 6A',
        'classTeacher': 'Thầy Nguyễn Văn Nam',
        'schoolName': 'Trường THCS Đại Việt',
        'educationLevel': 'SECONDARY',
        'educationLevelName': 'THCS',
      };
    } else if (u == 'student03' || u == 'hocsinh3.demo') {
      expectedPass = 'student123';
      demoUserData = {
        'id': '3',
        'username': 'Em Lê Hoàng Long',
        'roles': ['ROLE_STUDENT'],
        'token': 'mock_jwt_token_student03',
        'mustChangePassword': false,
        'grade': '10',
        'section': 'A',
        'className': 'Lớp 10A',
        'classTeacher': 'Thầy Vũ Đình Trọng',
        'schoolName': 'Trường THPT Đại Việt',
        'educationLevel': 'HIGH_SCHOOL',
        'educationLevelName': 'THPT',
      };
    } else if (u == 't001' || u == 'giaovien.demo') {
      expectedPass = 'teacher123';
      demoUserData = {
        'id': '1',
        'username': 'Cô Lê Thu Hà',
        'roles': ['ROLE_TEACHER'],
        'token': 'mock_jwt_token_teacher01',
        'mustChangePassword': false,
      };
    } else if (u == 'admin') {
      expectedPass = 'admin123';
      demoUserData = {
        'id': '1',
        'username': 'Quản trị viên Đại Việt',
        'roles': ['ROLE_ADMIN'],
        'token': 'mock_jwt_token_admin',
        'mustChangePassword': false,
      };
    } else if (u == '9910157611' || u == 'phuhuynh.demo') {
      expectedPass = '123456';
      demoUserData = {
        'id': '1',
        'username': 'Phụ huynh Nguyễn Văn Hùng',
        'roles': ['ROLE_PARENT'],
        'token': 'mock_jwt_token_parent',
        'mustChangePassword': false,
      };
    }

    if (demoUserData != null) {
      if (password == expectedPass ||
          password == 'student123' ||
          password == '123456') {
        final user = User.fromJson(demoUserData);
        if (user.token != null) {
          try {
            await _storage.write(key: 'jwt_token', value: user.token);
          } catch (_) {}
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(demoUserData));

        return {
          'success': true,
          'user': user,
          'mustChangePassword': false,
          'isDemo': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Tài khoản hoặc mật khẩu không chính xác.',
        };
      }
    }

    return {
      'success': false,
      'message': 'Tài khoản không tồn tại trong hệ thống demo.',
    };
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final token = await getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/change-password');
    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      ).timeout(ApiTimeoutPolicy.mutation.duration);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final rawUser = prefs.getString('user_data');
        if (rawUser != null) {
          final userMap = jsonDecode(rawUser);
          userMap['mustChangePassword'] = false;
          await prefs.setString('user_data', jsonEncode(userMap));
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Đổi mật khẩu thành công.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Không thể đổi mật khẩu.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final data = jsonDecode(userDataStr);
        return data['token'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // --- Backend OTP Methods (Legacy/Fast2SMS) ---
  Future<Map<String, dynamic>> sendOtpBackend(String phone) async {
    if (isDemoMode) {
      return {'success': true, 'message': 'Mã OTP demo là: 123456'};
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/send-otp');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      ).timeout(ApiTimeoutPolicy.mutation.duration);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Mã OTP đã được gửi.'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Không thể gửi mã OTP.'};
      }
    } catch (_) {
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ gửi OTP.'};
    }
  }

  Future<Map<String, dynamic>> verifyOtpBackend(
    String phone,
    String otp,
  ) async {
    if (isDemoMode) {
      return _tryDemoLogin(phone.isNotEmpty ? phone : '9910157611', '123456');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp');
    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      ).timeout(ApiTimeoutPolicy.mutation.duration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        if (user.token != null) {
          try {
            await _storage.write(key: 'jwt_token', value: user.token);
          } catch (_) {}
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

        return {'success': true, 'user': user};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Mã OTP không hợp lệ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối máy chủ: $e'};
    }
  }

  // --- Firebase OTP Methods ---
  Future<void> sendOtpFirebase({
    required String phone,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      onError('Firebase Auth is not initialized');
      return;
    }
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {
              await auth.signInWithCredential(credential);
              onSuccess('Auto-verified!');
            },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          onError(e.message ?? 'Firebase Verification Failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onSuccess('OTP Sent to $phone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyOtpFirebase(String smsCode) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return {'success': false, 'message': 'Firebase Auth is not initialized'};
    }
    if (_verificationId == null) {
      return {
        'success': false,
        'message': 'Verification ID not found. Send OTP first.',
      };
    }
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await auth.signInWithCredential(credential);
      return {'success': true, 'message': 'Firebase Login Success'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
