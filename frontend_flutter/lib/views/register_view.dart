import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_view.dart';
import '../services/api_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  int _currentStep = 1;

  // 步驟一：表單控制器
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _promoCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 步驟二：店家選擇（從 API 取得）
  int? _selectedStoreId;
  List<StoreItem> _stores = [];
  bool _storesLoading = true;
  String? _storesError;
  bool _isRegistering = false;
  String? _registerError;

  static const List<Color> _storeColors = [
    Color(0xFF3B82F6),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF0EA5E9),
  ];

  final ApiService _api = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _promoCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() {
      _storesLoading = true;
      _storesError = null;
    });
    try {
      final stores = await _api.fetchStores();
      if (mounted) {
        setState(() {
          _stores = stores;
          _storesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        setState(() {
          _storesError = msg.contains('DioException') || msg.contains('status code')
              ? '無法載入店家列表，請確認後端已啟動'
              : (msg.isNotEmpty ? msg : '無法載入店家列表，請稍後再試');
          _storesLoading = false;
        });
      }
    }
  }

  void _handleRegisterStep1() {
    // 驗證表單
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final idNumber = _idNumberController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showSnackBar('請輸入姓名');
      return;
    }
    if (email.isEmpty) {
      _showSnackBar('請輸入電子郵箱');
      return;
    }
    if (phone.isEmpty) {
      _showSnackBar('請輸入電話號碼');
      return;
    }
    if (idNumber.isEmpty) {
      _showSnackBar('請輸入身分證字號');
      return;
    }
    if (password.length < 8 || password != confirmPassword) {
      _showSnackBar('密碼格式錯誤未完整');
      return;
    }
    if (!_agreeTerms) {
      _showSnackBar('請同意服務條款與隱私政策');
      return;
    }

    setState(() {
      _currentStep = 2;
      _selectedStoreId = null;
      _registerError = null;
    });
    _loadStores();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _handleCompleteSetup() async {
    if (_selectedStoreId == null) return;

    setState(() {
      _isRegistering = true;
      _registerError = null;
    });

    try {
      await _api.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        idNumber: _idNumberController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        storeId: _selectedStoreId!,
        promoCode: _promoCodeController.text.trim().isEmpty ? null : _promoCodeController.text.trim(),
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRegistering = false;
          _registerError = e.toString().replaceFirst('Exception: ', '');
        });
        _showSnackBar(_registerError ?? '註冊失敗');
      }
    }
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
              Color(0xFF0F172A),
              Color(0xFF1E3A5F),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  // ========== 步驟一：填寫資料 ==========
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogoSection(title: '建立帳號', subtitle: '加入 TrackMe 追蹤系統', icon: Icons.location_on),
          const SizedBox(height: 32),
          _buildStep1Form(),
        ],
      ),
    );
  }

  Widget _buildStep1Form() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                label: '姓名',
                icon: Icons.person_outline,
                controller: _nameController,
                hintText: '請輸入您的姓名',
              ),
              const SizedBox(height: 20),
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
                label: '身分證字號',
                icon: Icons.badge_outlined,
                controller: _idNumberController,
                hintText: 'A123456789',
                maxLength: 10,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: '優惠代碼 (選填)',
                icon: Icons.local_offer_outlined,
                controller: _promoCodeController,
                hintText: '輸入優惠代碼享折扣',
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: '密碼',
                icon: Icons.lock_outline,
                controller: _passwordController,
                hintText: '至少 8 個字元',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.blue.shade300,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: '確認密碼',
                icon: Icons.lock_outline,
                controller: _confirmPasswordController,
                hintText: '再次輸入密碼',
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.blue.shade300,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              const SizedBox(height: 20),

              // 服務條款勾選框
              GestureDetector(
                onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreeTerms,
                        onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                        activeColor: const Color(0xFF06B6D4),
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFF06B6D4);
                          }
                          return Colors.transparent;
                        }),
                        side: BorderSide(color: Colors.blue.shade200, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('我同意 ', style: TextStyle(fontSize: 12, color: Colors.blue.shade200)),
                          GestureDetector(
                            onTap: () {},
                            child: const Text('服務條款', style: TextStyle(fontSize: 12, color: Color(0xFF22D3EE), decoration: TextDecoration.underline)),
                          ),
                          Text(' 和 ', style: TextStyle(fontSize: 12, color: Colors.blue.shade200)),
                          GestureDetector(
                            onTap: () {},
                            child: const Text('隱私政策', style: TextStyle(fontSize: 12, color: Color(0xFF22D3EE), decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 註冊帳號按鈕
              GestureDetector(
                onTap: _handleRegisterStep1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('註冊帳號', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 登入連結
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('已經有帳號了?', style: TextStyle(fontSize: 14, color: Colors.blue.shade200)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text('立即登入', style: TextStyle(fontSize: 14, color: Color(0xFF22D3EE), fontWeight: FontWeight.w600)),
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

  // ========== 步驟二：選擇店家 ==========
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogoSection(title: '選擇管理店家', subtitle: '請選擇您所屬的店家', icon: Icons.store_outlined),
          const SizedBox(height: 32),
          _buildStoreSelectionCard(),
        ],
      ),
    );
  }

  Widget _buildStoreSelectionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_storesLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE))),
                )
              else if (_storesError != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _storesError!,
                        style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _loadStores,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22D3EE).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF22D3EE)),
                          ),
                          child: const Text('重試', style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(_stores.length, (index) {
                  final store = _stores[index];
                  final isSelected = _selectedStoreId == store.id;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index < _stores.length - 1 ? 12 : 0),
                    child: _buildStoreCard(store: store, isSelected: isSelected),
                  );
                }),
              const SizedBox(height: 24),

              // 完成設定 / 請選擇店家 按鈕
              GestureDetector(
                onTap: (_selectedStoreId != null && !_isRegistering) ? _handleCompleteSetup : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: _selectedStoreId != null
                        ? const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                          )
                        : null,
                    color: _selectedStoreId == null ? Colors.white.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                    border: _selectedStoreId == null ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
                    boxShadow: _selectedStoreId != null
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRegistering)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      else ...[
                        Text(
                          _selectedStoreId != null ? '完成設定' : '請選擇店家',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _selectedStoreId != null ? Colors.white : Colors.blue.shade300,
                          ),
                        ),
                        if (_selectedStoreId != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '選擇後，您將由該店家進行管理',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade300),
                ),
              ),
              if (_selectedStoreId != null && _stores.isNotEmpty) ...[
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
                      const SizedBox(width: 6),
                      Text(
                        '已選擇 ${_stores.firstWhere((s) => s.id == _selectedStoreId).name}',
                        style: TextStyle(fontSize: 14, color: const Color(0xFF22D3EE)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard({required StoreItem store, required bool isSelected}) {
    final colorIndex = store.id % _storeColors.length;
    return GestureDetector(
      onTap: () => setState(() => _selectedStoreId = store.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF22D3EE) : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _storeColors[colorIndex].withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Text(
                          store.name.length > 0 ? store.name[0] : '',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade300),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.branchName,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade200),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF22D3EE), Color(0xFF06B6D4)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  // ========== 共用元件 ==========
  Widget _buildLogoSection({required String title, required String subtitle, required IconData icon}) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
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
          child: Icon(icon, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.blue.shade200)),
      ],
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
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue.shade200)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.blue.shade300.withOpacity(0.5), fontSize: 14),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(icon, size: 20, color: Colors.blue.shade300),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}
