import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view.dart';
import 'register_view.dart';
import 'forgot_password_view.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  final ApiService _api = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      _showSnackBar('請輸入電子郵箱');
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnackBar('請輸入有效的電子郵箱格式');
      return;
    }
    if (password.isEmpty || password.length < 8) {
      _showSnackBar('密碼格式錯誤未完整');
      return;
    }
    if (phone.isEmpty) {
      _showSnackBar('請輸入電話號碼');
      return;
    }
    if (!_isValidPhone(phone)) {
      _showSnackBar('請輸入有效的電話號碼（例：0912-345-678）');
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final res = await _api.login(
        email: email,
        password: password,
      );
      if (mounted) {
        final auth = context.read<AuthProvider>();
        final user = res['user'] as Map<String, dynamic>?;
        if (user != null && res['token'] != null) {
          await auth.setAuth(
            token: res['token'] as String,
            userId: user['id'] as int,
            name: user['name'] as String,
            email: user['email'] as String,
            phone: user['phone'] as String?,
            idNumber: user['id_number'] as String?,
            store: user['store'] is String ? user['store'] as String : null,
          );
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingIn = false);
        final msg = e.toString().replaceFirst('Exception: ', '');
        _showSnackBar(msg.isNotEmpty ? msg : '密碼有誤，請再查詢');
      }
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return false;
    // 09XXXXXXXX (10 碼)、+886 9XXXXXXXX (12 碼)、或 9XXXXXXXX (9 碼省略 0)
    if (RegExp(r'^09\d{8}$').hasMatch(digits)) return true;
    if (RegExp(r'^8869\d{8}$').hasMatch(digits)) return true;
    if (RegExp(r'^9\d{8}$').hasMatch(digits)) return true;
    return false;
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // slate-900
              Color(0xFF1E3A5F), // blue-900
              Color(0xFF0F172A), // slate-900
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo 區域
                _buildLogoSection(),

                const SizedBox(height: 32),

                // 玻璃感登入卡片
                _buildGlassCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // 藍色發光定位圖標
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6), // blue-500
                Color(0xFF06B6D4), // cyan-500
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'TrackMe',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '即時定位追蹤系統',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue.shade200,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                label: '電子郵箱',
                icon: Icons.mail_outline,
                controller: _emailController,
                hintText: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: '電話號碼',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                hintText: '0912-345-678',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: '密碼',
                icon: Icons.lock_outline,
                controller: _passwordController,
                hintText: '••••••••',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.blue.shade300,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 記住我 & 忘記密碼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _rememberMe = !_rememberMe);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) {
                              setState(() => _rememberMe = v ?? false);
                            },
                            activeColor: const Color(0xFF06B6D4),
                            fillColor: WidgetStateProperty.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF06B6D4);
                              }
                              return Colors.transparent;
                            }),
                            side: BorderSide(
                              color: Colors.blue.shade200,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '記住我',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordView(),
                        ),
                      );
                    },
                    child: Text(
                      '忘記密碼？',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF22D3EE), // cyan-400
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 登入按鈕
              GestureDetector(
                onTap: _isLoggingIn ? null : _handleLogin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: _isLoggingIn
                        ? null
                        : const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF06B6D4),
                            ],
                          ),
                    color: _isLoggingIn ? Colors.grey : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isLoggingIn
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isLoggingIn
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '登入',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 底部註冊連結
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '還沒有帳號？',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade200,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterView()),
                      );
                    },
                    child: const Text(
                      ' 立即註冊',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF22D3EE), // cyan-400 亮藍色
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade200,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.blue.shade300.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  icon,
                  size: 20,
                  color: Colors.blue.shade300,
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
