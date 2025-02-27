class MoneyTransaction {
  final int? id;
  final DateTime? updateTime; // 수정 시간
  final String transactionTime; // 거래 시간
  // final String account;
  final double amount;
  final String goods;
  final String category;
  final String categoryType;
  final String? description;
  final String? parameter;
  final bool extraBudget;
  // final int? installment;

  MoneyTransaction({
    this.id,
    this.updateTime,
    required this.transactionTime,
    // required this.account,
    required this.amount,
    required this.goods,
    this.category="미분류",
    this.categoryType="미지정",
    this.description ="",
    this.parameter ="",
    this.extraBudget = false,
    // this.installment = 1,
  });

  /// Transaction을 Map<String, dynamic>으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'updateTime': updateTime?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'transactionTime': transactionTime,
      // 'account': account,
      'amount': amount,
      'goods': goods,
      'category': category!="" ? category : "미분류",
      'categoryType': categoryType!="" ? categoryType : "미지정",
      'description': description!="" ? description : " ",
      'parameter': parameter!="" ? parameter : "{}",
      'extraBudget': extraBudget ? 1 : 0,
      // 'installment': installment,
    };
  }

  /// Transactiondml 카데고리/ 상품명 일괄관리용
  Map<String, dynamic> toMapforCategoryGoodsRelation() {
    return {
      'goods': goods,
      'category': category!="" ? category : "미분류",
    };
  }

  MoneyTransaction copyWith({
    int? id,
    DateTime? updateTime,
    String? transactionTime,
    double? amount,
    String? goods,
    String? category,
    String? categoryType,
    String? description,
    String? parameter,
    bool? extraBudget,
    // int? installment,
  }) {
    return MoneyTransaction(
      id: id ?? this.id,
      updateTime: updateTime ?? this.updateTime,
      transactionTime: transactionTime ?? this.transactionTime,
      amount: amount ?? this.amount,
      goods: goods ?? this.goods,
      category: category ?? this.category,
      categoryType: categoryType ?? this.categoryType,
      description: description ?? this.description,
      parameter: parameter ?? this.parameter,
      extraBudget: extraBudget ?? this.extraBudget,
      // installment: installment ?? this.installment,
    );
  }
}