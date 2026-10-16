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
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/signin');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        if (user.token != null) {
          await _storage.write(key: 'jwt_token', value: user.token);
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
          'message': data['message'] ?? 'Invalid Credentials',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
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
    return await _storage.read(key: 'jwt_token');
  }

  // --- Backend OTP Methods (Legacy/Fast2SMS) ---
  Future<Map<String, dynamic>> sendOtpBackend(String phone) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP Sent via Backend'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtpBackend(
    String phone,
    String otp,
  ) async {
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
          await _storage.write(key: 'jwt_token', value: user.token);
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));

        return {'success': true, 'user': user};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
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
