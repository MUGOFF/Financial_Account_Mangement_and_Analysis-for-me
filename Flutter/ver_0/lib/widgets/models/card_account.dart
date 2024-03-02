class CardAccount {
  final int? id;
  final int? cardIssuer;
  final String cardName;
  final String? cardNumber;
  final String? memo;

  CardAccount({
    this.id,
    this.cardIssuer,
    required this.cardName,
    this.cardNumber,
    this.memo,
  });

  Map<String, dynamic> toMap() {
    return {
      'cardIssuer': cardIssuer,
      'cardName': cardName,
      'cardNumber': cardNumber,
      'memo': memo,
    };
  }
}