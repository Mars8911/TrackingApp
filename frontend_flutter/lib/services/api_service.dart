// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../models/loan_summary.dart';

class ApiService {
  // 對於 Chrome 開發，使用 localhost
  // 對於 Android 模擬器，需改為 10.0.2.2
  // 對於實機，需改為電腦的局域網 IP (如 192.168.1.x)
  final String baseUrl = "http://localhost:8000/api";
  final Dio _dio = Dio();

  Future<LoanSummary> fetchDashboardSummary() async {
    try {
      // 呼叫你的 Laravel API 路由
      final response = await _dio.get('$baseUrl/dashboard');

      if (response.statusCode == 200) {
        // 抓取 JSON 中的 summary 部分並轉換
        return LoanSummary.fromJson(response.data['data']['summary']);
      } else {
        throw Exception('伺服器回應錯誤: ${response.statusCode}');
      }
    } catch (e) {
      print('API 連線失敗: $e');
      throw Exception('無法連線至後端伺服器，請確認 Docker 是否啟動。');
    }
  }
}
