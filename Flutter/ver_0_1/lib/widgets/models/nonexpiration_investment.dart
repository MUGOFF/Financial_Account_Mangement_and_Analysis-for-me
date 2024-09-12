class NonexpirationInvestment {
  final int? id;
  final DateTime? updateTime; // 수정 시간
  final String investTime; 
  final String account;
  final double amount;
  final double cost;
  final double valuePrice;
  final String investment;
  final String investcategory;
  final String currency;
  final String? description;

  NonexpirationInvestment({
    this.id,
    this.updateTime,
    required this.investTime,
    this.account = "미등록",
    required this.amount,
    required this.cost,
    required this.valuePrice,
    required this.investment,
    this.investcategory="미분류",
    this.currency="KRW",
    this.description ="",
  });

  // Transaction을 Map<String, dynamic>으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'updateTime': updateTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'investTime': investTime,
      'account': account,
      'amount': amount,
      'cost': cost,
      'valuePrice': valuePrice,
      'investment': investment,
      'investcategory': investcategory,
      'currency': currency,
      'description': description,
    };
  }
}