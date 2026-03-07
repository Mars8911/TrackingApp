import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// 首頁訊息類型
enum MessageType { dongBao, realEstate, other }

/// 訊息類型（用於顯示左側圓點顏色）
enum MessageStatus { reminder, success }

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  MessageType _selectedMessageType = MessageType.dongBao;

  // 還款資訊（可之後由 Provider/Bloc 取得）
  final double _repaymentTotal = 1384567;
  final double _repaidAmount = 1;
  final double _monthlyPayment = 101092;

  double get _repaymentProgress =>
      _repaymentTotal > 0 ? (_repaidAmount / _repaymentTotal) * 100 : 0;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'zh_TW',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D1117),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildRepaymentCard(),
                const SizedBox(height: 32),
                _buildMessagesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 頂部：會員中心標題 + 一般會員按鈕
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2A4A7A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '會員中心',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A店家',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Text(
            '一般會員',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// 還款資訊卡片
  Widget _buildRepaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF243B5C),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '\$ 還款資訊',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '還款總額',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(_repaymentTotal),
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '已還款進度',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              Text(
                '${_repaymentProgress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LinearProgressIndicator(
              value: _repaymentProgress / 100,
              backgroundColor: const Color(0xFF3D3D3D),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
              minHeight: 14,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _buildSubCard(
                  label: '已還款金額',
                  amount: _repaidAmount,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSubCard(
                  label: '每月應還款',
                  amount: _monthlyPayment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubCard({required String label, required double amount}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B4A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(amount),
            style: GoogleFonts.lexend(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 首頁訊息區塊
  Widget _buildMessagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '首頁訊息',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                _buildFilterChip('動保', MessageType.dongBao),
                const SizedBox(width: 10),
                _buildFilterChip('不動產', MessageType.realEstate),
                const SizedBox(width: 10),
                _buildFilterChip('其他', MessageType.other),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        ..._buildMessageList(),
      ],
    );
  }

  Widget _buildFilterChip(String label, MessageType type) {
    final isSelected = _selectedMessageType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedMessageType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2A4A7A)
              : const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMessageList() {
    // 模擬資料，可之後改為從 API 取得
    final messages = [
      _MessageItem(
        status: MessageStatus.reminder,
        title: '汽車貸款繳款提醒',
        content: '車牌 ABC-1234 本月還款日為 3/5, 應繳 NT\$92,592',
        date: '2026-03-01',
      ),
      _MessageItem(
        status: MessageStatus.success,
        title: '機車貸款付款成功',
        content: '車牌 XYZ-9876 已成功繳納 2 月份款項 NT\$8,500',
        date: '2026-02-15',
      ),
    ];

    return messages
        .map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMessageCard(m),
            ))
        .toList();
  }

  Widget _buildMessageCard(_MessageItem item) {
    final dotColor = item.status == MessageStatus.reminder
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.date,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageItem {
  final MessageStatus status;
  final String title;
  final String content;
  final String date;

  _MessageItem({
    required this.status,
    required this.title,
    required this.content,
    required this.date,
  });
}
