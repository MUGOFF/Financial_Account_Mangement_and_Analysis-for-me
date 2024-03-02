class MoneyTransaction {
  final int? id;
  final DateTime? updateTime; // 수정 시간
  final String transactionTime; // 거래 시간
  final String account;
  final double amount;
  final String goods;
  final String category;
  final String? description;

  MoneyTransaction({
    this.id,
    this.updateTime,
    required this.transactionTime,
    required this.account,
    required this.amount,
    required this.goods,
    this.category="미분류",
    this.description ="",
  });

  // Transaction을 Map<String, dynamic>으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'updateTime': updateTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'transactionTime': transactionTime,
      'account': account,
      'amount': amount,
      'goods': goods,
      'category': category,
      'description': description,
    };
  }
}