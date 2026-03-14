import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../constants/dashboard_design.dart';
import '../models/loan.dart';
import '../models/loan_summary.dart';

/// 會員中心：標題「會員中心」+「王小明的借貸資訊」+ 頭像，借貸列表表格與總筆數／總月繳摘要卡
class MemberCenterView extends StatefulWidget {
  const MemberCenterView({
    super.key,
    this.summary,
    this.userName = '王小明',
  });

  final LoanSummary? summary;
  final String userName;

  @override
  State<MemberCenterView> createState() => _MemberCenterViewState();
}

class _MemberCenterViewState extends State<MemberCenterView> {
  static const int _initialVisibleCount = 3;
  bool _showAll = false;

  /// 無 API 資料時顯示空列表（新註冊用戶無貸款）
  List<Loan> get _loans => widget.summary?.loans ?? <Loan>[];
  int get _totalCases => widget.summary?.totalCases ?? _loans.length;
  /// 全部借貸的月還款加總（API 未提供時為 0，UI 以設計稿範例值顯示）
  double get _totalMonthlyPayment => _loans.fold<double>(
        0,
        (s, l) => s + (l.monthlyPayment ?? 0),
      );

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'zh_TW',
    symbol: 'NT:',
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
                _buildLoanTableCard(),
                const SizedBox(height: 16),
                _buildSummaryCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 頂部：左側標題＋副標靠左、右側頭像靠右（左右分開到靠邊緣）
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '會員中心',
              style: TextStyle(
                color: Colors.white,
                fontSize: DashboardDesign.fontSizeLg,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.userName}的借貸資訊',
              style: TextStyle(
                color: DashboardDesign.textBlue300,
                fontSize: DashboardDesign.fontSizeXs,
              ),
            ),
          ],
        ),
        _buildAvatar(),
      ],
    );
  }

  /// 紅底白字按鈕（展開／收起共用）：Colors.red、寬度與表格一致、borderRadius 12
  Widget _buildExpandCollapseButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: DashboardDesign.fontSizeSm,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = widget.userName.isNotEmpty ? widget.userName[0] : '?';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: DashboardDesign.accentGradient,
        borderRadius: BorderRadius.circular(DashboardDesign.radiusXl),
        boxShadow: [
          BoxShadow(
            color: DashboardDesign.blue500.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 尚無貸款時顯示的空白狀態
  Widget _buildEmptyLoanCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: DashboardDesign.white5,
            borderRadius:
                BorderRadius.circular(DashboardDesign.radius2xl),
            border: Border.all(
              color: DashboardDesign.borderWhite10,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 48, color: DashboardDesign.textBlue300),
              const SizedBox(height: 12),
              Text(
                '尚無貸款案件',
                style: TextStyle(
                  color: DashboardDesign.textBlue200,
                  fontSize: DashboardDesign.fontSizeBase,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 借貸列表卡片：Column + 獨立列容器（非 DataTable）、標題列加深＋上圓角、收合按鈕紅底白字
  Widget _buildLoanTableCard() {
    if (_loans.isEmpty) {
      return _buildEmptyLoanCard();
    }
    final displayLoans = _showAll
        ? _loans
        : _loans.take(_initialVisibleCount).toList();
    final hiddenCount = _loans.length - _initialVisibleCount;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題列 + 資料列：一起水平滑動、欄位對齊
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.sizeOf(context).width -
                        DashboardDesign.spacing4 * 2 -
                        24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTableHeader(context),
                      ...displayLoans.asMap().entries.map((entry) {
                        final index = entry.key;
                        final loan = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            top: index == 0
                                ? DashboardDesign.spacing2
                                : 0,
                            bottom: index < displayLoans.length - 1
                                ? DashboardDesign.spacing2
                                : 0,
                          ),
                          child: _buildLoanRow(context, loan),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              if (displayLoans.isNotEmpty)
                SizedBox(height: displayLoans.length > 1 ? 0 : DashboardDesign.spacing2),
              // 收合按鈕：紅底白字、寬度與表格一致、borderRadius 12
              if (hiddenCount > 0 && !_showAll)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DashboardDesign.spacing3,
                    DashboardDesign.spacing2,
                    DashboardDesign.spacing3,
                    DashboardDesign.spacing3,
                  ),
                  child: _buildExpandCollapseButton(
                    label: 'SHOW ${_loans.length} 筆 其餘隱藏',
                    icon: Icons.keyboard_arrow_down_rounded,
                    onTap: () => setState(() => _showAll = true),
                  ),
                )
              else if (_loans.length > _initialVisibleCount && _showAll)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DashboardDesign.spacing3,
                    DashboardDesign.spacing2,
                    DashboardDesign.spacing3,
                    DashboardDesign.spacing3,
                  ),
                  child: _buildExpandCollapseButton(
                    label: '收起',
                    icon: Icons.keyboard_arrow_up_rounded,
                    onTap: () => setState(() => _showAll = false),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 標題列：背景加深、上方圓角（與資料列一起水平滑動）
  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardDesign.spacing3,
        vertical: DashboardDesign.spacing3,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // slate-900 加深
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _headerCell('筆', 36, TextAlign.left),
          _headerCell('擔保品', 56, TextAlign.left),
          _headerCell('借貸金額', 140, TextAlign.left),
              _headerCell('月還款金額', 120, TextAlign.center),
              _headerCell('還款日', 80, TextAlign.center),
        ],
      ),
    );
  }

  Widget _headerCell(String text, double width, TextAlign align) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: DashboardDesign.textBlue300,
          fontSize: DashboardDesign.fontSizeSm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 單一借貸列：無邊框、與標題列對齊
  Widget _buildLoanRow(BuildContext context, Loan loan) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DashboardDesign.spacing3,
        vertical: DashboardDesign.spacing3,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${loan.id}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  loan.caseName ?? '貸款 #${loan.id}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: DashboardDesign.green400,
                    fontSize: DashboardDesign.fontSizeSm,
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: _buildLoanAmountCell(loan),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  loan.monthlyPayment != null
                      ? _currencyFormat.format(loan.monthlyPayment!)
                      : '--',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  loan.repaymentDay ?? '--',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DashboardDesign.fontSizeSm,
                  ),
                ),
              ),
            ],
          ),
    );
  }


  /// 借貸金額格：本金／尚餘 上到下呈現（標籤在上、金額在下，皆左對齊）
  Widget _buildLoanAmountCell(Loan loan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '本金',
          style: TextStyle(
            fontSize: DashboardDesign.fontSizeXs,
            color: DashboardDesign.textBlue300,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _currencyFormat.format(loan.amount),
          style: TextStyle(
            fontSize: DashboardDesign.fontSizeSm,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '尚餘',
          style: TextStyle(
            fontSize: DashboardDesign.fontSizeXs,
            color: DashboardDesign.textBlue300,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _currencyFormat.format(loan.remaining),
          style: TextStyle(
            fontSize: DashboardDesign.fontSizeSm,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 總借貸筆數、總月繳金額 兩張並排卡片
  Widget _buildSummaryCards() {
    final totalMonthly = _totalMonthlyPayment > 0
        ? _totalMonthlyPayment
        : 163115.0; // 設計稿範例值，當 API 無月還款時使用

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            label: '總借貸筆數',
            value: '$_totalCases',
            isBlue: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            label: '總月繳金額',
            value: _currencyFormat.format(totalMonthly),
            isBlue: false,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required bool isBlue,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DashboardDesign.radius2xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: DashboardDesign.blurXl,
          sigmaY: DashboardDesign.blurXl,
        ),
        child: Container(
          padding: const EdgeInsets.all(DashboardDesign.spacing4),
          decoration: BoxDecoration(
            gradient: isBlue
                ? DashboardDesign.cardGradient
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x33A855F7), // purple-500 20%
                      Color(0x33EC4899), // pink-500 20%
                    ],
                  ),
            borderRadius:
                BorderRadius.circular(DashboardDesign.radius2xl),
            border: Border.all(color: DashboardDesign.white20, width: 1),
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
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
}
