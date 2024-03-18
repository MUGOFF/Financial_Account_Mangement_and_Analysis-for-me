import 'dart:ffi';

class InvestAccount {
  final int? id;
  final String bankName;
  final String? accountNumber;
  final List<DepositCurrency>? deposit;
  final String? memo;

  InvestAccount({
    this.id,
    required this.bankName,
    this.accountNumber,
    this.deposit, 
    this.memo,
  });

  // Convert InvestAccount object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'memo': memo,
    };
  }
}

class DepositCurrency {
  String currencyName;
  Double depositAmount;

  DepositCurrency({
    required this.currencyName,
    required this.depositAmount,
  });
}