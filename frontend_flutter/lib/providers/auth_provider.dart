import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 會員登入狀態（Token + 使用者資訊）
class AuthProvider extends ChangeNotifier {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'auth_user_id';
  static const _keyUserName = 'auth_user_name';
  static const _keyUserEmail = 'auth_user_email';
  static const _keyUserPhone = 'auth_user_phone';
  static const _keyUserIdNumber = 'auth_user_id_number';
  static const _keyUserStore = 'auth_user_store';

  String? _token;
  int? _userId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  String? _userIdNumber;
  String? _userStore;

  String? get token => _token;
  int? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  String? get userIdNumber => _userIdNumber;
  String? get userStore => _userStore;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_keyToken);
    _userId = prefs.getInt(_keyUserId);
    _userName = prefs.getString(_keyUserName);
    _userEmail = prefs.getString(_keyUserEmail);
    _userPhone = prefs.getString(_keyUserPhone);
    _userIdNumber = prefs.getString(_keyUserIdNumber);
    _userStore = prefs.getString(_keyUserStore);
    notifyListeners();
  }

  Future<void> setAuth({
    required String token,
    required int userId,
    required String name,
    required String email,
    String? phone,
    String? idNumber,
    String? store,
  }) async {
    _token = token;
    _userId = userId;
    _userName = name;
    _userEmail = email;
    _userPhone = phone ?? '';
    _userIdNumber = idNumber ?? '';
    _userStore = store ?? '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserName, name);
    await prefs.setString(_keyUserEmail, email);
    await prefs.setString(_keyUserPhone, _userPhone!);
    await prefs.setString(_keyUserIdNumber, _userIdNumber!);
    await prefs.setString(_keyUserStore, _userStore!);
    notifyListeners();
  }

  void updateProfileFromApi(Map<String, dynamic> user) {
    _userName = user['name'] as String? ?? _userName;
    _userEmail = user['email'] as String? ?? _userEmail;
    _userPhone = user['phone'] as String? ?? _userPhone ?? '';
    _userIdNumber = user['id_number'] as String? ?? _userIdNumber ?? '';
    _userStore = user['store'] as String? ?? _userStore ?? '';
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
    _userPhone = null;
    _userIdNumber = null;
    _userStore = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserIdNumber);
    await prefs.remove(_keyUserStore);
    notifyListeners();
  }
}
