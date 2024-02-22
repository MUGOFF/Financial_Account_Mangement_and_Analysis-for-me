class BankAccount {
  final int id;
  final String accountNumber;
  final double balance;

  BankAccount({required this.id, required this.accountNumber, required this.balance});

  // Convert BankAccount object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'balance': balance,
    };
  }
}