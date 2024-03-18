class TransactionCategory {
  final int? id;
  final String name;
  final List<String>? itemList;

  TransactionCategory({
    this.id,
    required this.name,
    required this.itemList,
  });

  // Convert object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'itemList':itemList?.join(',')
    };
  }
}