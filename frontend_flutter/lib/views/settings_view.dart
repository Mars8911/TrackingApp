import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/dashboard_design.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

/// 個人設定頁（對應 design_assets SettingsPage + 截圖設計稿）
/// 包含：頂部個人卡片、個人資訊列表、安全設定、版本資訊
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.token!.isEmpty) return;
    final user = await _api.fetchProfile(auth.token!);
    if (user != null && mounted) {
      context.read<AuthProvider>().updateProfileFromApi(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: DashboardDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Expanded(
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final userInfo = _SettingsUserInfo(
                      name: auth.userName ?? '',
                      email: auth.userEmail ?? '',
                      phone: auth.userPhone ?? '',
                      idNumber: auth.userIdNumber ?? '',
                      store: auth.userStore ?? '',
                    );
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        DashboardDesign.spacing4,
                        DashboardDesign.spacing4,
                        DashboardDesign.spacing4,
                        80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(userInfo),
                          const SizedBox(height: 16),
                          _buildSectionTitle('個人資訊'),
                          const SizedBox(height: 8),
                          _buildPersonalInfoCard(userInfo),
                          const SizedBox(height: 16),
                          _buildSectionTitle('安全設定'),
                          const SizedBox(height: 8),
                          _buildSecurityCard(context),
                          const SizedBox(height: 24),
                          _buildVersionFooter(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 頁面標題：個人設定 + 管理您的個人資訊
  Widget _buildHeader() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          padding: const EdgeInsets.all(DashboardDesign.spacing4),
          decoration: BoxDecoration(
            color: DashboardDesign.headerSlate800.withOpacity(0.5),
            border: const Border(
              bottom: BorderSide(
                color: DashboardDesign.borderWhite10,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '個人設定',
                style: GoogleFonts.notoSansTc(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSizeXl,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '管理您的個人資訊',
                style: GoogleFonts.notoSansTc(
                  color: DashboardDesign.textBlue300,
                  fontSize: DashboardDesign.fontSizeXs,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 頂部個人卡片：藍色發光頭像（含綠點）+ 姓名 + Email + A 店家標籤
  Widget _buildProfileCard(_SettingsUserInfo userInfo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DashboardDesign.spacing4),
          decoration: BoxDecoration(
            gradient: DashboardDesign.cardGradient,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radius2xl),
            border: Border.all(color: DashboardDesign.white20, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAvatarWithStatus(userInfo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userInfo.name,
                      style: GoogleFonts.notoSansTc(
                        color: Colors.white,
                        fontSize: DashboardDesign.fontSizeLg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userInfo.email,
                      style: GoogleFonts.notoSansTc(
                        color: DashboardDesign.textBlue200,
                        fontSize: DashboardDesign.fontSizeXs,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildStoreBadge(userInfo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus(_SettingsUserInfo userInfo) {
    final initial =
        userInfo.name.isNotEmpty ? userInfo.name[0] : '?';
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: DashboardDesign.accentGradient,
              borderRadius:
                  BorderRadius.circular(DashboardDesign.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: DashboardDesign.blue500.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.notoSansTc(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: DashboardDesign.green400,
                shape: BoxShape.circle,
                border: Border.all(
                  color: DashboardDesign.bgSlate900,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreBadge(_SettingsUserInfo userInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: DashboardDesign.blue500.withOpacity(0.2),
        borderRadius:
            BorderRadius.circular(DashboardDesign.radiusLg),
        border: Border.all(
          color: DashboardDesign.blue500.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        userInfo.store,
        style: GoogleFonts.notoSansTc(
          color: DashboardDesign.textBlue300,
          fontSize: DashboardDesign.fontSizeXs,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.notoSansTc(
          color: DashboardDesign.textBlue300,
          fontSize: DashboardDesign.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 個人資訊列表：姓名、電子郵箱、電話、身分證、所屬店家
  /// 每個項目左側彩色圖示（藍、青、綠、紫、橘），右側「不可更改」
  Widget _buildPersonalInfoCard(_SettingsUserInfo userInfo) {
    return _buildFrostedCard(
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            iconGradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
            label: '姓名',
            value: userInfo.name,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.mail_outline_rounded,
            iconGradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
            label: '電子郵箱',
            value: userInfo.email,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            iconGradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            label: '電話號碼',
            value: userInfo.phone,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            iconGradient: const [Color(0xFFA855F7), Color(0xFF9333EA)],
            label: '身分證字號',
            value: userInfo.idNumber,
          ),
          _buildInfoDivider(),
          _buildInfoRow(
            icon: Icons.store_outlined,
            iconGradient: const [Color(0xFFF97316), Color(0xFFEA580C)],
            label: '所屬店家',
            value: userInfo.store,
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: DashboardDesign.white5,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radius2xl),
            border: Border.all(
              color: DashboardDesign.borderWhite10,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required List<Color> iconGradient,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(DashboardDesign.spacing4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: iconGradient,
              ),
              borderRadius:
                  BorderRadius.circular(DashboardDesign.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: iconGradient.first.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSansTc(
                    color: DashboardDesign.textBlue300,
                    fontSize: DashboardDesign.fontSizeXs,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.notoSansTc(
                    color: Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '不可更改',
            style: GoogleFonts.notoSansTc(
              color: DashboardDesign.textBlue300,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Divider(
      height: 1,
      indent: 52,
      endIndent: DashboardDesign.spacing4,
      color: DashboardDesign.white5,
    );
  }

  /// 安全設定：更改密碼
  Widget _buildSecurityCard(BuildContext context) {
    return _buildFrostedCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onChangePasswordTap(context),
          borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
          child: Padding(
            padding: const EdgeInsets.all(DashboardDesign.spacing4),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    borderRadius:
                        BorderRadius.circular(DashboardDesign.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '更改密碼',
                        style: GoogleFonts.notoSansTc(
                          color: Colors.white,
                          fontSize: DashboardDesign.fontSizeSm,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '定期更改密碼保護帳號安全',
                        style: GoogleFonts.notoSansTc(
                          color: DashboardDesign.textBlue300,
                          fontSize: DashboardDesign.fontSizeXs,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: DashboardDesign.textBlue300,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'TrackMe v2.5.1',
            style: GoogleFonts.notoSansTc(
              color: DashboardDesign.textBlue300,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 TrackMe Inc.',
            style: GoogleFonts.notoSansTc(
              color: DashboardDesign.blue400,
              fontSize: DashboardDesign.fontSizeXs,
            ),
          ),
        ],
      ),
    );
  }

  void _onChangePasswordTap(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _ChangePasswordDialog(
        api: _api,
        token: context.read<AuthProvider>().token ?? '',
        onSuccess: () {
          Navigator.pop(ctx);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('密碼已更新')),
            );
          }
        },
      ),
    );
  }
}

/// 更改密碼對話框
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog({
    required this.api,
    required this.token,
    required this.onSuccess,
  });

  final ApiService api;
  final String token;
  final VoidCallback onSuccess;

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final newPwd = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty) {
      setState(() => _errorMsg = '請輸入目前密碼');
      return;
    }
    if (newPwd.length < 8) {
      setState(() => _errorMsg = '新密碼至少 8 個字元');
      return;
    }
    if (newPwd != confirm) {
      setState(() => _errorMsg = '兩次密碼輸入不一致');
      return;
    }

    setState(() {
      _errorMsg = null;
      _isSubmitting = true;
    });

    try {
      await widget.api.changePassword(
        token: widget.token,
        currentPassword: current,
        newPassword: newPwd,
        newPasswordConfirmation: confirm,
      );
      if (mounted) {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Widget _buildPasswordInput({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansTc(
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
            style: GoogleFonts.notoSansTc(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.notoSansTc(
                color: Colors.blue.shade300.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: Colors.blue.shade300,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: Colors.blue.shade300,
                ),
                onPressed: onToggleVisibility,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '更改密碼',
                    style: GoogleFonts.notoSansTc(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPasswordInput(
                    label: '目前密碼',
                    hintText: '••••••••',
                    controller: _currentController,
                    obscureText: _obscureCurrent,
                    onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordInput(
                    label: '新密碼',
                    hintText: '至少 8 字元',
                    controller: _newController,
                    obscureText: _obscureNew,
                    onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordInput(
                    label: '確認新密碼',
                    hintText: '••••••••',
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMsg!,
                      style: GoogleFonts.notoSansTc(
                        color: const Color(0xFFF87171),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          child: Text(
                            '取消',
                            style: GoogleFonts.notoSansTc(
                              color: Colors.blue.shade200,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: _isSubmitting ? null : _submit,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: _isSubmitting
                                  ? null
                                  : const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF3B82F6),
                                        Color(0xFF06B6D4),
                                      ],
                                    ),
                              color: _isSubmitting ? Colors.grey : null,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isSubmitting
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
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      '確認',
                                      style: GoogleFonts.notoSansTc(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsUserInfo {
  const _SettingsUserInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.idNumber,
    required this.store,
  });
  final String name;
  final String email;
  final String phone;
  final String idNumber;
  final String store;
}
