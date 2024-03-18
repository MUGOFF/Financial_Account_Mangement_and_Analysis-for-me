class ExpirationInvestment {
  final int? id;
  final DateTime? updateTime; // 수정 시간
  final String investTime; 
  final String expirationTime; 
  final double interestRate; 
  final String account;
  final double amount;
  final double cost;
  final double valuePrice;
  final String investment;
  final String investcategory;
  final String currency;
  final String? description;

  ExpirationInvestment({
    this.id,
    this.updateTime,
    required this.investTime,
    required this.expirationTime,
    this.interestRate = 0.0,
    this.account = "비증권계좌",
    required this.amount,
    required this.cost,
    required this.valuePrice,
    required this.investment,
    this.investcategory="미분류",
    this.currency="KRW",
    this.description ="",
  });

  // Map<String, dynamic>으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'updateTime': updateTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'investTime': investTime,
      'expirationTime': expirationTime,
      'interestRate': interestRate,
      'account': account,
      'amount': amount,
      'valuePrice': valuePrice,
      'cost': cost,
      'investment': investment,
      'investcategory': investcategory,
      'currency': currency,
      'description': description,
    };
  }
}