import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ashadeep/utils/constants.dart';
import 'package:ashadeep/core/services/auth_service.dart';
import 'package:ashadeep/core/models/user.dart';
import 'package:ashadeep/features/admin/screens/dashboard_screen.dart';
import 'package:ashadeep/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:ashadeep/features/parent/screens/parent_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController(); // For Admin/Teacher
  final _otpController = TextEditingController(); // For Parent
  final FocusNode _otpFocusNode = FocusNode();

  final _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.admin; // Default

  // Country Code State
  String _selectedCountryCode = '+91';
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'name': 'India'},
    {'code': '+1', 'name': 'USA'},
    {'code': '+44', 'name': 'UK'},
  ];

  // OTP State
  bool _isOtpSent = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == UserRole.parent) {
        if (!_isOtpSent) {
          _sendOtp();
        } else {
          _verifyOtp();
        }
      } else {
        _loginWithPassword();
      }
    }
  }

  void _sendOtp() async {
    if (_idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter Phone Number")));
      return;
    }

    setState(() => _isLoading = true);

    // Using Backend OTP Flow explicitly for local development debugging
    final result = await _authService.sendOtpBackend(_idController.text.trim());

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Sent. Check the Backend Terminal.")),
      );
      // Automatically focus the OTP field
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).requestFocus(_otpFocusNode);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _verifyOtp() async {
    setState(() => _isLoading = true);

    final backendResult = await _authService.verifyOtpBackend(
      _idController.text.trim(),
      _otpController.text.trim(),
    );

    setState(() => _isLoading = false);
    _handleLoginResult(backendResult);
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
              'Warning: Logged in as ${user.role.name.toUpperCase()} but selected ${_selectedRole.name.toUpperCase()} tab.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Welcome, ${user.name}!')));

      if (user.role == UserRole.admin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (user.role == UserRole.teacher) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TeacherDashboardScreen(
              teacherId: user.id,
              teacherName: user.name,
            ),
          ),
        );
      } else if (user.role == UserRole.parent) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ParentDashboardScreen(),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login failed'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
              content: Text('Press back again to exit'),
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
        backgroundColor: AppColors.backgroundOf(context),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.school,
                  size: 80,
                  color: AppColors.primaryOf(context),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1(context),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(context),
                ),
                const SizedBox(height: 40),

                // Role Selection
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltOf(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildRoleButton('Admin', UserRole.admin),
                      _buildRoleButton('Teacher', UserRole.teacher),
                      _buildRoleButton('Parent', UserRole.parent),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceOf(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username / Phone Input
                        TextFormField(
                          key: ValueKey('id_field_${_selectedRole.name}'),
                          controller: _idController,
                          decoration: InputDecoration(
                            labelText: _selectedRole == UserRole.parent
                                ? 'Phone Number'
                                : _getLabelText(),
                            prefixIcon: _selectedRole == UserRole.parent
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: AppColors.borderOf(context),
                                        ),
                                      ),
                                    ),
                                    width: 110, // Adjust width as needed
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCountryCode,
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down),
                                        items: _countryCodes.map((country) {
                                          return DropdownMenuItem<String>(
                                            value: country['code'],
                                            child: Text(
                                              '${country['code']} (${country['name']})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedCountryCode = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.badge,
                                    color: AppColors.primaryOf(context),
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.borderOf(context),
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceAltOf(context),
                          ),
                          keyboardType: _selectedRole == UserRole.parent
                              ? TextInputType.phone
                              : TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password OR OTP Input
                        if (_selectedRole == UserRole.parent && _isOtpSent)
                          TextFormField(
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Enter OTP',
                              prefixIcon: Icon(
                                Icons.lock_clock,
                                color: AppColors.primaryOf(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceAltOf(context),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) =>
                                value!.isEmpty ? 'Enter OTP' : null,
                          )
                        else if (_selectedRole != UserRole.parent)
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock,
                                color: AppColors.primaryOf(context),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.textTertiaryOf(context),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderOf(context),
                                ),
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceAltOf(context),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                        if (_selectedRole != UserRole.parent)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Forgot Password?'),
                            ),
                          )
                        else
                          const SizedBox(height: 20),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOf(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    _selectedRole == UserRole.parent
                                        ? (_isOtpSent
                                              ? 'Verify & Login'
                                              : 'Send OTP')
                                        : 'Login',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        if (_selectedRole == UserRole.parent && _isOtpSent)
                          TextButton(
                            onPressed: () => setState(() => _isOtpSent = false),
                            child: const Text("Change Phone Number"),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String text, UserRole role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
            _isOtpSent = false; // Reset OTP state on role change
            _idController.clear();
            _passwordController.clear();
            _otpController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceOf(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AppColors.primaryOf(context)
                  : AppColors.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }

  String _getLabelText() {
    switch (_selectedRole) {
      case UserRole.admin:
        return 'Admin ID';
      case UserRole.teacher:
        return 'Teacher ID';
      case UserRole.parent:
        return 'Parent Phone';
    }
  }
}
