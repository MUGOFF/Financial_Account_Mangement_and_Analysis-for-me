import 'dart:convert';

class BudgetSetting {
  final int? id;
  final int year;
  final int month;
  final Map<String, double>? budgetList;

  BudgetSetting({
    this.id,
    required this.year,
    required this.month,
    required this.budgetList,
  });

  // Convert object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'budgetList':json.encode(budgetList)
    };
  }
}
