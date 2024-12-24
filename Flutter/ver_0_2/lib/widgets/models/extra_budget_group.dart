import 'dart:convert';

class ExtraBudgetGroup {
  final int? id;
  final Map<String, dynamic>? dataList;

  ExtraBudgetGroup({
    this.id,
    required this.dataList,
  });

  // Convert object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'dataList': dataList != null ? json.encode(dataList): {}
    };
  }
}