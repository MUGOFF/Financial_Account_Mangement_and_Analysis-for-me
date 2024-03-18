class Holdings {
  final int? id;
  final String investment;
  final double totalAmount;
  final String investcategory;
  final String currency;

  Holdings({
    required this.id,
    required this.investment,
    required this.totalAmount,
    required this.investcategory,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'investment': investment,
      'totalAmount': totalAmount,
      'investcategory': investcategory,
      'currency': currency,
    };
  }
}