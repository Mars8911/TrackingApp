import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/dashboard_design.dart';
import '../models/loan.dart';
import '../models/loan_summary.dart';

/// 首頁訊息篩選類型（保留供日後依案件類型篩選）
enum MessageType { dongBao, realEstate, other }

class DashboardView extends StatefulWidget {
  const DashboardView({
    super.key,
    this.summary,
  });

  /// 來自 API 的還款摘要（由 HomeView FutureBuilder snapshot.data 傳入）
  final LoanSummary? summary;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  MessageType _selectedMessageType = MessageType.dongBao;

  /// 無貸款時顯示 0，有 API 資料時顯示實際值
  double get _repaymentTotal =>
      widget.summary?.totalLoanAmount ?? 0;
  double get _repaidAmount =>
      widget.summary != null
          ? (widget.summary!.totalLoanAmount - widget.summary!.totalRemaining)
          : 0;
  /// 月還款：有 API 時從 loans 加總，無則為 0
  double get _monthlyPayment => widget.summary?.loans.fold<double>(
        0,
        (s, l) => s + (l.monthlyPayment ?? 0),
      ) ?? 0;

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
          gradient: DashboardDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              DashboardDesign.spacing4,
              DashboardDesign.spacing4,
              DashboardDesign.spacing4,
              80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildRepaymentCard(),
                const SizedBox(height: 16),
                _buildMessagesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 頂部：會員中心 + 店家名 + 一般會員（與設計稿一致）
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(
        left: DashboardDesign.spacing4,
        right: DashboardDesign.spacing4,
        top: DashboardDesign.spacing4,
        bottom: DashboardDesign.spacing3,
      ),
      decoration: const BoxDecoration(
        gradient: DashboardDesign.headerGradient,
        border: Border(
          bottom: BorderSide(color: DashboardDesign.borderWhite10, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: DashboardDesign.accentGradient,
                  borderRadius:
                      BorderRadius.circular(DashboardDesign.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: DashboardDesign.blue500.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.store_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '會員中心',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DashboardDesign.fontSizeLg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'A店家',
                    style: TextStyle(
                      color: DashboardDesign.textBlue300,
                      fontSize: DashboardDesign.fontSizeXs,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DashboardDesign.spacing3,
              vertical: 6,
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
              '一般會員',
              style: TextStyle(
                color: DashboardDesign.textBlue300,
                fontSize: DashboardDesign.fontSizeXs,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 還款資訊卡片（磨砂玻璃：backdrop-blur-xl + 漸層 + 白邊）
  Widget _buildRepaymentCard() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.attach_money_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '還款資訊',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: DashboardDesign.fontSizeBase,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '還款總額',
                style: TextStyle(
                  color: DashboardDesign.textBlue200,
                  fontSize: DashboardDesign.fontSizeSm,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currencyFormat.format(_repaymentTotal),
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSize3xl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已還款進度',
                    style: TextStyle(
                      color: DashboardDesign.textBlue200,
                      fontSize: DashboardDesign.fontSizeXs,
                    ),
                  ),
                  Text(
                    '${_repaymentProgress.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: DashboardDesign.textBlue200,
                      fontSize: DashboardDesign.fontSizeXs,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 12,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final progress = (_repaymentProgress / 100).clamp(0.0, 1.0);
                      return Stack(
                        children: [
                          Container(
                            width: w,
                            decoration: BoxDecoration(
                              color: DashboardDesign.white10,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: w * progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: DashboardDesign.progressGradient,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSubCard(
                      label: '已還款金額',
                      amount: _repaidAmount,
                    ),
                  ),
                  const SizedBox(width: 12),
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
        ),
      ),
    );
  }

  /// 子卡片：磨砂玻璃 backdrop-blur-sm + bg-white/10
  Widget _buildSubCard({required String label, required double amount}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurSm,
          sigmaY: DashboardDesign.blurSm,
        ),
        child: Container(
          padding: const EdgeInsets.all(DashboardDesign.spacing3),
          decoration: BoxDecoration(
            color: DashboardDesign.white10,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radiusXl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: DashboardDesign.textBlue200,
                  fontSize: DashboardDesign.fontSizeXs,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _currencyFormat.format(amount),
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSizeXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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
            Text(
              '首頁訊息',
              style: TextStyle(
                color: Colors.white,
                fontSize: DashboardDesign.fontSizeLg,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip('動保', MessageType.dongBao),
                const SizedBox(width: 6),
                _buildFilterChip('不動產', MessageType.realEstate),
                const SizedBox(width: 6),
                _buildFilterChip('其他', MessageType.other),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildMessageList(),
      ],
    );
  }

  Widget _buildFilterChip(String label, MessageType type) {
    final isSelected = _selectedMessageType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedMessageType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: DashboardDesign.spacing3,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? DashboardDesign.accentGradient : null,
          color: isSelected ? null : DashboardDesign.white10,
          borderRadius:
              BorderRadius.circular(DashboardDesign.radiusLg),
          border: isSelected
              ? null
              : Border.all(
                  color: DashboardDesign.borderWhite10,
                  width: 1,
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DashboardDesign.blue500.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : DashboardDesign.textBlue300,
            fontSize: DashboardDesign.fontSizeXs,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMessageList() {
    final loans = widget.summary?.loans ?? <Loan>[];
    return loans
        .map((loan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLoanMessageCard(loan),
            ))
        .toList();
  }

  /// 依貸款餘額決定左側圓點顏色：餘額 > 0 橘色（提醒），否則綠色（已清償）
  Color _dotColorForRemaining(double remaining) {
    return remaining > 0
        ? DashboardDesign.orange400
        : DashboardDesign.green400;
  }

  Widget _buildLoanMessageCard(Loan loan) {
    final dotColor = _dotColorForRemaining(loan.remaining);
    final title = loan.caseName ?? '貸款 #${loan.id}';
    final subtitle = loan.storeName;

    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DashboardDesign.spacing4),
          decoration: BoxDecoration(
            color: DashboardDesign.white5,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radiusXl),
            border: Border.all(
              color: DashboardDesign.borderWhite10,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: DashboardDesign.fontSizeSm,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: DashboardDesign.textBlue200,
                        fontSize: DashboardDesign.fontSizeXs,
                      ),
                    ),
                    if (loan.remaining >= 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '餘額 ${_currencyFormat.format(loan.remaining)}',
                        style: TextStyle(
                          color: DashboardDesign.textBlue300,
                          fontSize: DashboardDesign.fontSizeXs,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
