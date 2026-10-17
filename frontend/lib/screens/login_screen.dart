import "package:ashadeep/features/student/screens/student_dashboard_screen.dart";
import "package:ashadeep/features/auth/screens/force_change_password_screen.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/core/widgets/app_loading_button.dart';
import 'package:ashadeep/features/admin/screens/dashboard_screen.dart';
import 'package:ashadeep/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_dashboard_screen.dart';

// Bộ màu chuẩn định nghĩa từ bản mẫu HTML demo
const Color _kPrimaryBlue = Color(0xFF2457C5); // Mã màu xanh chuẩn HTML demo
const Color _kTextMain = Color(0xFF202124);    // Màu chữ chính đen đậm #202124
const Color _kTextSub = Color(0xFF5F6368);     // Màu chữ phụ #5F6368
const Color _kBorderColor = Color(0xFF5F6368); // Viền ô nhập #5F6368
const Color _kErrColor = Color(0xFFC62828);    // Màu đỏ báo lỗi #C62828

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.student; // Default: Học sinh (vai trò đầu tiên từ trái sang)

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _loginWithPassword();
    }
  }

  void _loginWithPassword() async {
    setState(() => _isLoading = true);
    final result = await _authService.login(
      _idController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    _handleLoginResult(result);
  }

  void _handleLoginResult(Map<String, dynamic> result) {
    if (result['success'] == true) {
      final user = result['user'] as User;
      if (!mounted) return;

      // Verify role match
      if (user.role != _selectedRole) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lưu ý: Bạn đã đăng nhập với vai trò ${_getRoleDisplayName(user.role)}.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chào mừng, ${user.name}!')));

      if (user.mustChangePassword) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ForceChangePasswordScreen(user: user),
          ),
        );
        return;
      }

      if (user.role == UserRole.student) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const StudentDashboardScreen(),
          ),
        );
        return;
      } else if (user.role == UserRole.admin) {
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
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đăng nhập không thành công'),
          backgroundColor: _kErrColor,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: _kPrimaryBlue),
            SizedBox(width: 8),
            Text(
              'Quên mật khẩu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _kTextMain),
            ),
          ],
        ),
        content: const Text(
          'Vui lòng liên hệ quản trị viên nhà trường hoặc GVCN để cấp lại mật khẩu.',
          style: TextStyle(fontSize: 15, height: 1.4, color: _kTextMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold, color: _kPrimaryBlue)),
          ),
        ],
      ),
    );
  }

  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
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
              content: Text('Nhấn thêm lần nữa để thoát ứng dụng'),
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
        backgroundColor: Colors.white,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header căn lề trái theo phong cách hiện đại và mẫu HTML demo
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _kPrimaryBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 30,
                          color: _kPrimaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'HỆ THỐNG GIÁO DỤC',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: _kTextSub,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đăng nhập',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _kTextMain,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Boxtext: Tên đăng nhập hoặc số điện thoại (với hiệu ứng Floating Label animation khi ấn vào)
                    TextFormField(
                      key: ValueKey('id_field_${_selectedRole.name}'),
                      controller: _idController,
                      style: const TextStyle(
                        color: _kTextMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: _kPrimaryBlue,
                      decoration: const InputDecoration(
                        labelText: 'Tên đăng nhập hoặc số điện thoại',
                        labelStyle: TextStyle(color: _kTextSub, fontSize: 14),
                        floatingLabelStyle: TextStyle(
                          color: _kPrimaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: Icon(Icons.person_outline, color: _kTextSub, size: 22),
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hoverColor: Colors.white,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kBorderColor, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kBorderColor, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kPrimaryBlue, width: 2.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kErrColor, width: 1.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kErrColor, width: 2.0),
                        ),
                        errorStyle: TextStyle(color: _kErrColor, fontSize: 12),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên đăng nhập hoặc số điện thoại';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Boxtext: Mật khẩu (với hiệu ứng Floating Label animation khi ấn vào)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(
                        color: _kTextMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      cursorColor: _kPrimaryBlue,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: const TextStyle(color: _kTextSub, fontSize: 14),
                        floatingLabelStyle: const TextStyle(
                          color: _kPrimaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: const Icon(Icons.lock_outline, color: _kTextSub, size: 22),
                        filled: true,
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        hoverColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.only(left: 12, right: 0, top: 14, bottom: 14),
                        suffixIcon: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(color: _kBorderColor, width: 1.0),
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              minimumSize: const Size(60, 48),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Text(
                              _isPasswordVisible ? 'Ẩn' : 'Hiện',
                              style: const TextStyle(
                                color: _kPrimaryBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kBorderColor, width: 1.0),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kBorderColor, width: 1.0),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kPrimaryBlue, width: 2.0),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kErrColor, width: 1.0),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: _kErrColor, width: 2.0),
                        ),
                        errorStyle: const TextStyle(color: _kErrColor, fontSize: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Label: Vai trò
                    const Text(
                      'Vui lòng chọn vai trò và đăng nhập vào hệ thống',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kTextMain,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Thanh chọn vai trò: 4 vai trò Việt hóa với viền xanh #2457C5, cao đúng 44px
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _kPrimaryBlue,
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Row(
                        children: [
                          _buildRoleButton('Học sinh', UserRole.student, isLast: false),
                          _buildRoleButton('Phụ huynh', UserRole.parent, isLast: false),
                          _buildRoleButton('Giáo viên', UserRole.teacher, isLast: false),
                          _buildRoleButton('Quản trị', UserRole.admin, isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nút Đăng nhập: cao đúng 48px, nền xanh #2457C5, chữ trắng font 16 w600
                    AppLoadingButton(
                      text: 'Đăng nhập',
                      loadingText: 'Đang xác thực...',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                      backgroundColor: _kPrimaryBlue,
                      borderRadius: BorderRadius.circular(8),
                      height: 48,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Nút Quên mật khẩu: chữ xanh #2457C5, font 15 w600, căn lề trái như HTML demo
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _kPrimaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Footer ghi chú nhỏ ở đáy
                    const Text(
                      'Hệ thống Quản lý Giáo dục - Phiên bản 1.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: _kTextSub,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String text, UserRole role, {bool isLast = false}) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _idController.clear();
            _passwordController.clear();
          });
        },
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? _kPrimaryBlue : Colors.white,
            borderRadius: BorderRadius.zero,
            border: isLast
                ? null
                : const Border(
                    right: BorderSide(
                      color: _kPrimaryBlue,
                      width: 1.2,
                    ),
                  ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : _kPrimaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị';
      case UserRole.teacher:
        return 'Giáo viên';
      case UserRole.parent:
        return 'Phụ huynh';
      case UserRole.student:
        return 'Học sinh';
    }
  }
}
