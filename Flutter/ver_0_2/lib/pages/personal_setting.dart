import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:ver_0_2/widgets/database_admin.dart';


class PersonalSettings extends StatefulWidget {
  const PersonalSettings({super.key});

  @override
  State<PersonalSettings> createState() => _PersonalSettingsState();
}

class _PersonalSettingsState extends State<PersonalSettings> {
  bool isInstallmentSpread = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isInstallmentSpread = prefs.getBool('intallmentCalculation') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
    await DatabaseAdmin().initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // ListTile(
          //   title: const Text('할부 예산 반영'),
          //   trailing: Switch(
          //     value: true,
          //     onChanged: (bool value) {
          //       // setState(() {
          //       //   _isTagSwitched = value;
          //       // });
          //     },
          //   ),
          // ),
          // const Divider(),
          SwitchListTile(
            title: const Text('할부 예산 반영'),
            value: isInstallmentSpread,
            onChanged: (bool value) {
              setState(() {
                isInstallmentSpread = value;
              });
              _saveSetting('intallmentCalculation', value);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('정기 지출 관리'),
            trailing: IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PeriodicTrasnsasctionAdmin(),
                  ),
                );
              }, 
              icon: const Icon(Icons.arrow_forward_ios_rounded)
            )
          ),
          const Divider(),
        ]
      )
    );
  }
}

class PeriodicTrasnsasctionAdmin extends StatefulWidget {
  const PeriodicTrasnsasctionAdmin({super.key});

  @override
  State<PeriodicTrasnsasctionAdmin> createState() => _PeriodicTrasnsasctionAdminState();
}

class _PeriodicTrasnsasctionAdminState extends State<PeriodicTrasnsasctionAdmin> {
  Logger logger = Logger();
  List<Map<String, dynamic>> transactionDatas = [];

  @override
  void initState() {
    super.initState();
    _fetchDatas();
  }
  
  Future<void> _fetchDatas() async {
    List<Map<String, dynamic>> fetchedTransactions = await DatabaseAdmin().getPeriodTransactionList();

    fetchedTransactions.sort((a, b) => a['day'].compareTo(b['day']));

    setState(() {
      transactionDatas = fetchedTransactions;
    });
  }
  
  /// 거래 수정/삭제 다이얼로그
void _editDeleteDialog(int index) {
  var transaction = transactionDatas[index];

  TextEditingController dayController =
      TextEditingController(text: transaction['day'].toString());
  TextEditingController amountController =
      TextEditingController(text: transaction['amount'].toString());
  TextEditingController nameController =
      TextEditingController(text: transaction['name']);
  TextEditingController categoryTypeController =
      TextEditingController(text: transaction['categoryType']);
  TextEditingController categoryController =
      TextEditingController(text: transaction['category']);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("거래 수정/삭제"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "날짜"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "금액"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "거래명"),
              ),
              TextField(
                controller: TextEditingController(text: "소비"), // 기본값 "소비"
                decoration: const InputDecoration(labelText: "카테고리 타입"),
                readOnly: true, // 사용자가 수정할 수 없도록 설정
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "카테고리"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              _deleteTransaction(
                transaction['id'],
                dayController.text,
                amountController.text,
                nameController.text,
                categoryTypeController.text,
                categoryController.text,
              );
              Navigator.pop(context);
              _fetchDatas();
            },
            child: const Text("삭제"),
          ),
          TextButton(
            onPressed: () {
              int? dayValue = int.tryParse(dayController.text);
              if (dayValue == null || dayValue >= 31) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("날짜는 31 미만이어야 합니다.")),
                );
                return;
              }
              _updateTransaction(
                transaction['id'],
                dayController.text,
                amountController.text,
                nameController.text,
                categoryTypeController.text,
                categoryController.text,
              );
              Navigator.pop(context);
              _fetchDatas();
            },
            child: const Text("저장"),
          ),
        ],
      );
    },
  );
}

  /// 거래 추가 다이얼로그
  void _addTransactionDialog() {
    TextEditingController dayController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController categoryTypeController = TextEditingController();
    TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("정기 거래 추가"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "날짜"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "금액"),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "거래명"),
              ),
              TextField(
                controller: TextEditingController(text: "소비"), // 기본값 "소비"
                decoration: const InputDecoration(labelText: "카테고리 타입"),
                readOnly: true, // 사용자가 수정할 수 없도록 설정
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "카테고리"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                int? dayValue = int.tryParse(dayController.text);
                if (dayValue == null || dayValue >= 31) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("날짜는 31 미만이어야 합니다.")),
                  );
                  return;
                }
                _insertTransaction(
                dayController.text,
                amountController.text,
                nameController.text,
                categoryTypeController.text,
                categoryController.text,
              );
                Navigator.pop(context);
                _fetchDatas();
              },
              child: const Text("추가"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("정기 지출 목록")),
      body: transactionDatas.isEmpty
          ? const Center(child: Text("등록된 거래가 없습니다."))
          : ListView.builder(
              itemCount: transactionDatas.length,
              itemBuilder: (context, index) {
                var transaction = transactionDatas[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                      "${transaction['name']} (${transaction['day']}일)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "금액: ${transaction['amount']}원 | 카테고리: ${transaction['category']}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blueAccent),
                    onTap: () => _editDeleteDialog(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransactionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 거래 삽입 함수
  Future<void> _insertTransaction(
    String day,
    String amount,
    String name,
    String categoryType,
    String category,
  ) async {
    await DatabaseAdmin().insertPeriodTransaction({
      'day': int.tryParse(day) ?? 1,
      'amount': double.tryParse(amount) ?? 0.0,
      'name': name,
      'categoryType': categoryType,
      'category': category,
    });
    _fetchDatas();
  }

  /// 거래 수정 함수
  Future<void> _updateTransaction(
    int id,
    String day,
    String amount,
    String name,
    String categoryType,
    String category,
  ) async {
    await DatabaseAdmin().updatePeriodTransaction({
      'id': id,
      'day': int.tryParse(day) ?? 1,
      'amount': double.tryParse(amount) ?? 0.0,
      'name': name,
      'categoryType': categoryType,
      'category': category,
    });
    _fetchDatas();
  }

  /// 거래 삭제 함수
  Future<void> _deleteTransaction(
    int id,
    String day,
    String amount,
    String name,
    String categoryType,
    String category,
  ) async {
    await DatabaseAdmin().deletePeriodTransaction({'id': id});
    _fetchDatas();
  }

}