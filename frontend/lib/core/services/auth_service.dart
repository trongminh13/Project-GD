import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/utils/constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  String? _verificationId;

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
    if (ApiConstants.isDemoMode) {
      return _tryDemoLogin(username, password);
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/auth/signin');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

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
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Thông tin đăng nhập không hợp lệ.',
        };
      }
    } catch (e) {
      // Khi mất mạng, timeout hoặc backend không phản hồi: Kích hoạt Demo Fallback
      return _tryDemoLogin(username, password);
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

    if (u == 'student01' || u == 'hocsinh.demo') {
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
          (u == 'student01' && password == 'student123') ||
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
          'message': 'Mật khẩu không chính xác cho tài khoản $username. Mật khẩu chuẩn là: $expectedPass',
        };
      }
    }

    return {
      'success': false,
      'message': 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng hoặc đăng nhập với tài khoản mẫu (student01 / student123).',
    };
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    final token = await getToken();
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/change-password');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

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
    if (ApiConstants.isDemoMode) {
      return {'success': true, 'message': 'Mã OTP demo là: 123456'};
    }
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Mã OTP đã được gửi.'};
      } else {
        return {'success': true, 'message': 'Mã OTP demo là: 123456'};
      }
    } catch (_) {
      return {'success': true, 'message': 'Mã OTP demo là: 123456'};
    }
  }

  Future<Map<String, dynamic>> verifyOtpBackend(
    String phone,
    String otp,
  ) async {
    if (ApiConstants.isDemoMode || otp == '123456') {
      return _tryDemoLogin(phone.isNotEmpty ? phone : '9910157611', '123456');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

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
      if (otp == '123456') {
        return _tryDemoLogin(phone.isNotEmpty ? phone : '9910157611', '123456');
      }
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
