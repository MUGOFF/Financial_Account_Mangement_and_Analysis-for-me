class BankAccount {
  final int? id;
  final String bankName;
  final String? accountNumber;
  final double? balance;
  final String? memo;

  BankAccount({
    this.id,
    required this.bankName,
    this.accountNumber,
    this.balance = 0, 
    this.memo,
  });

  // Convert BankAccount object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'balance': balance,
      'memo': memo,
    };
  }
}