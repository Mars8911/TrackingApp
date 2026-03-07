// lib/views/home_view.dart — 首頁／導航入口
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // 需要安裝 intl 套件：flutter pub add intl
import '../models/loan_summary.dart';
import '../services/api_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 初始化 API 服務
  final ApiService _apiService = ApiService();

  // 用於存儲非同步抓取的資料狀態
  late Future<LoanSummary> _loanSummaryFuture;

  // 金額格式化工具 (加上逗號)
  final currencyFormat = NumberFormat("#,##0", "zh_TW");

  @override
  void initState() {
    super.initState();
    // 頁面一載入就開始抓資料
    _loanSummaryFuture = _apiService.fetchDashboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // 深色背景
      body: SafeArea(
        child: FutureBuilder<LoanSummary>(
          future: _loanSummaryFuture,
          builder: (context, snapshot) {
            // 狀態 1：資料載入中 (顯示旋轉進度條)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            // 狀態 2：連線發生錯誤 (例如 Docker 沒開)
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 重新嘗試抓取
                        setState(() {
                          _loanSummaryFuture = _apiService
                              .fetchDashboardSummary();
                        });
                      },
                      child: const Text('重試'),
                    ),
                  ],
                ),
              );
            }

            // 狀態 3：成功抓到資料 (活資料來了！)
            final summary = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 頂部卡片區 (對應截圖藍色漸層區) ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '還款總額',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        // 活資料 1: 格式化後的總金額
                        Text(
                          '\$${currencyFormat.format(summary.totalLoanAmount)}',
                          style: GoogleFonts.lexend(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- 圓環進度條 (對應截圖圓環) ---
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                // 活資料 2: 還款進度百分比 (0.0 ~ 1.0)
                                value: summary.repaymentProgress,
                                strokeWidth: 15,
                                backgroundColor: Colors.white10,
                                color: Colors.blueAccent,
                              ),
                            ),
                            // 中間顯示百分比文字
                            Text(
                              '${(summary.repaymentProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- 下方數據列 (對應截圖已還款/每月應還) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoStat(
                              '已還款金額',
                              '\$${currencyFormat.format(summary.totalLoanAmount - summary.totalRemaining)}',
                            ),
                            _buildInfoStat('案件總數', '${summary.totalCases} 案'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    '首頁訊息',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- 列表區 (對應截圖下方列表) ---
                  // 這裡我們暫時用死的 ListTile 模擬樣式
                  _buildMessageCard('汽車貸款 - 台北店', '提醒：動保設定中', Colors.orange),
                  _buildMessageCard('不動產貸款 - 台中店', '提醒：估價已完成', Colors.green),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 小組件：數據統計
  Widget _buildInfoStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 小組件：訊息卡片
  Widget _buildMessageCard(String title, String subtitle, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: statusColor, radius: 6),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white30,
          size: 16,
        ),
      ),
    );
  }
}
