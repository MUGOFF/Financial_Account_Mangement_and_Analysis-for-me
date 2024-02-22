class Transaction {
  final int id;
  final int accountId; // Foreign key referencing BankAccount
  final double amount;
  final DateTime timestamp;

  Transaction({required this.id, required this.accountId, required this.amount, required this.timestamp});

  // Convert Transaction object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to string
    };
  }
}