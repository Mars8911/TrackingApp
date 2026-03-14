// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../models/loan_summary.dart';

/// 店家資料（供註冊選擇）
class StoreItem {
  final int id;
  final String name;
  final String branchName;

  StoreItem({
    required this.id,
    required this.name,
    required this.branchName,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as int,
      name: json['name'] as String,
      branchName: json['branch_name'] as String,
    );
  }
}

/// 註冊結果
class RegisterResult {
  final int userId;
  final String name;
  final String email;
  final int storeId;

  RegisterResult({
    required this.userId,
    required this.name,
    required this.email,
    required this.storeId,
  });

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return RegisterResult(
      userId: user['id'] as int,
      name: user['name'] as String,
      email: user['email'] as String,
      storeId: user['store_id'] as int,
    );
  }
}

class ApiService {
  // 對於 Chrome 開發，使用 localhost
  // 對於 Android 模擬器，需改為 10.0.2.2
  // 對於實機，需改為電腦的局域網 IP (如 192.168.1.x)
  final String baseUrl = "http://localhost:8000/api";
  final Dio _dio = Dio();

  /// 取得店家列表（供註冊時選擇）
  Future<List<StoreItem>> fetchStores() async {
    try {
      final response = await _dio.get('$baseUrl/stores');
      if (response.statusCode == 200) {
        final list = response.data['stores'] as List;
        return list.map((e) => StoreItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('無法載入店家列表，請稍後再試');
    } on DioException catch (e) {
      print('API 連線失敗: $e');
      if (e.response?.statusCode == 500) {
        throw Exception('伺服器忙碌中，請確認後端已啟動且資料庫連線正常');
      }
      throw Exception('無法連線至伺服器，請確認後端已啟動');
    } catch (e) {
      print('API 連線失敗: $e');
      rethrow;
    }
  }

  /// 會員註冊
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String idNumber,
    required String password,
    required String passwordConfirmation,
    required int storeId,
    String? promoCode,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'id_number': idNumber,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'store_id': storeId,
        },
      );
      if (response.statusCode == 201) {
        return RegisterResult.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('註冊失敗');
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String msg = '驗證失敗';
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          msg = first is List ? (first.isNotEmpty ? first.first.toString() : msg) : first.toString();
        }
        throw Exception(msg);
      }
      print('API 連線失敗: $e');
      rethrow;
    }
  }

  /// 會員登入
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('登入失敗');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final msg = e.response?.data['message'] as String? ?? '密碼有誤，請再查詢';
        throw Exception(msg);
      }
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        String msg = '驗證失敗';
        if (errors != null && errors.isNotEmpty) {
          final first = errors.values.first;
          msg = first is List ? (first.isNotEmpty ? first.first.toString() : msg) : first.toString();
        }
        throw Exception(msg);
      }
      print('API 連線失敗: $e');
      rethrow;
    }
  }

  /// 取得會員個人資料（需 Bearer Token）
  Future<Map<String, dynamic>?> fetchProfile(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/user',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final user = response.data['user'] as Map<String, dynamic>?;
        return user != null ? Map<String, dynamic>.from(user) : null;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return null;
      print('API 取得個人資料失敗: $e');
      return null;
    } catch (e) {
      print('API 取得個人資料失敗: $e');
      return null;
    }
  }

  /// 更改密碼（需 Bearer Token）
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode != 200) {
        final msg = response.data['message'] as String? ?? '密碼更新失敗';
        throw Exception(msg);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final msg = e.response?.data['message'] as String? ?? '驗證失敗';
        throw Exception(msg);
      }
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message'] as String);
      }
      throw Exception('密碼更新失敗，請稍後再試');
    }
  }

  /// 取得推播通知列表（需 Bearer Token）
  Future<List<Map<String, dynamic>>> fetchNotifications(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/notifications',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>?;
        final list = data?['notifications'] as List? ?? [];
        return list
            .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return [];
      print('API 推播通知失敗: $e');
      return [];
    } catch (e) {
      print('API 推播通知失敗: $e');
      return [];
    }
  }

  /// 標記通知為已讀（需 Bearer Token）
  Future<bool> markNotificationAsRead(String token, int id) async {
    try {
      final response = await _dio.post(
        '$baseUrl/notifications/$id/read',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API 標記已讀失敗: $e');
      return false;
    }
  }

  Future<LoanSummary> fetchDashboardSummary() async {
    try {
      // 呼叫你的 Laravel API 路由
      final response = await _dio.get('$baseUrl/dashboard');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final summaryJson = Map<String, dynamic>.from(data['summary'] as Map<String, dynamic>);
        summaryJson['loans'] = data['loans'] ?? [];
        return LoanSummary.fromJson(summaryJson);
      } else {
        throw Exception('伺服器回應錯誤: ${response.statusCode}');
      }
    } catch (e) {
      print('API 連線失敗: $e');
      throw Exception('無法連線至後端伺服器，請確認 Docker 是否啟動。');
    }
  }
}
