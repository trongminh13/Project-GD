import 'package:flutter/material.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/features/student/screens/student_dashboard_screen.dart';
import 'package:ashadeep/features/admin/screens/dashboard_screen.dart';
import 'package:ashadeep/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_dashboard_screen.dart';

class ForceChangePasswordScreen extends StatefulWidget {
  final User user;

  const ForceChangePasswordScreen({super.key, required this.user});

  @override
  State<ForceChangePasswordScreen> createState() => _ForceChangePasswordScreenState();
}

class _ForceChangePasswordScreenState extends State<ForceChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submitChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService().changePassword(
      _oldPassController.text.trim(),
      _newPassController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đổi mật khẩu thành công!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to the proper destination based on role
      Widget target;
      if (widget.user.role == UserRole.student) {
        target = const StudentDashboardScreen();
      } else if (widget.user.role == UserRole.admin) {
        target = const DashboardScreen();
      } else if (widget.user.role == UserRole.teacher) {
        target = TeacherDashboardScreen(
          teacherId: widget.user.id,
          teacherName: widget.user.name,
        );
      } else {
        target = const ParentDashboardScreen();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => target),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Đổi mật khẩu thất bại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi Mật Khẩu Bắt Buộc'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_reset, size: 56, color: AppColors.lightPrimary),
                      const SizedBox(height: 16),
                      Text(
                        'Cập Nhật Mật Khẩu Lần Đầu',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading2(context),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tài khoản của bạn được khởi tạo với mật khẩu mặc định. Vui lòng đặt mật khẩu mới để tiếp tục.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body(context).copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _oldPassController,
                        obscureText: _obscureOld,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại (mặc định)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureOld = !_obscureOld),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _newPassController,
                        obscureText: _obscureNew,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                          if (v == _oldPassController.text) return 'Mật khẩu mới không được trùng mật khẩu cũ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmPassController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          prefixIcon: const Icon(Icons.check_circle_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v != _newPassController.text) return 'Mật khẩu xác nhận không khớp';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitChangePassword,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('XÁC NHẬN ĐỔI MẬT KHẨU', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
