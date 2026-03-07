// lib/models/loan_summary.dart

class LoanSummary {
  final int totalCases;
  final double totalLoanAmount;
  final double totalRemaining;
  final double repaymentProgress; // 計算出的進度：(總額-剩餘)/總額

  LoanSummary({
    required this.totalCases,
    required this.totalLoanAmount,
    required this.totalRemaining,
    required this.repaymentProgress,
  });

  // 工廠模式：將後端 JSON 轉換為 Flutter 物件
  factory LoanSummary.fromJson(Map<String, dynamic> json) {
    final amount = double.parse(json['total_loan_amount'].toString());
    final remaining = double.parse(json['total_remaining'].toString());

    // 計算還款進度百分比 (0.0 ~ 1.0)
    double progress = 0.0;
    if (amount > 0) {
      progress = (amount - remaining) / amount;
    }

    return LoanSummary(
      totalCases: json['total_cases'],
      totalLoanAmount: amount,
      totalRemaining: remaining,
      repaymentProgress: progress,
    );
  }
}
