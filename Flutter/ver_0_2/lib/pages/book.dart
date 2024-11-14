import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ver_0_2/widgets/drawer_end.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/pages/book_add.dart';

class Book extends StatefulWidget {
  const Book({super.key});
  
  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  Logger logger = Logger();
  final ScrollController _scrollController = ScrollController();
  PersistentBottomSheetController? bottomButtonController;
  bool _isVisible = true; // 플로팅 버튼이 보이는지 여부를 나타내는 변수
  int initialFilterState = 0;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  List<MoneyTransaction> transactions = [];
  Set<int> selectedIds = {};
  bool isSelectionMode = false;
  List<String> filterValue = ['소비', '수입'];
  String? transactionFilter = '기본';
  String? lastTopDatetime;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _scrollController.addListener(_scrollListener);
    // logger.d(transactions);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchTransactions() async {
    List<MoneyTransaction> fetchedTransactions = await DatabaseAdmin().getTransactionsByMonth(year, month);
    // 날짜 형식에 맞는 DateFormat 생성
    DateFormat format = DateFormat("yyyy년 MM월 dd일'T'HH:mm");

    fetchedTransactions.sort((a, b) {
      DateTime dateA = format.parse(a.transactionTime); // String -> DateTime 변환
      DateTime dateB = format.parse(b.transactionTime); // String -> DateTime 변환
      return dateA.compareTo(dateB); // DateTime으로 정렬
    });
    setState(() {
      transactions = fetchedTransactions;
    });
  }

  String formatterK(num number) {
    late String fString;
    late String addon;
    String preproNumber;
    if(number % 1 == 0) {
      preproNumber = (number * -1).toStringAsFixed(0);
    } else {
      preproNumber =  (number * -1).toString();
    }

    if(preproNumber.contains('.')) {
      fString = preproNumber.split('.')[0];
      addon = ".${preproNumber.split('.')[1]}";
    } else {
      fString = preproNumber;
      addon = "";
    }

    final String newText = fString.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
    return '$newText$addon';
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward || _scrollController.offset == _scrollController.position.minScrollExtent) {
      DateTime datetiemInitValue = DateFormat('yyyy년 MM월 dd일THH:mm').parse(transactions[0].transactionTime);
      String initTopDatetime= DateFormat('yyyy년 MM월 dd일').format(datetiemInitValue);
      lastTopDatetime = initTopDatetime;
      setState(() {
        _isVisible = true;
      });
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_scrollController.hasClients) {
        int index = (_scrollController.offset / 56).floor();
        DateTime datetiemValue = DateFormat('yyyy년 MM월 dd일THH:mm').parse(transactions[index].transactionTime);
        String currentTopDatetime= DateFormat('yyyy년 MM월 dd일').format(datetiemValue);
        lastTopDatetime ??= currentTopDatetime;

        if (lastTopDatetime != currentTopDatetime) {
          lastTopDatetime = currentTopDatetime;

          // Toast 메시지 표시
          _showDateToast('$lastTopDatetime');
        }
      }
      setState(() {
        _isVisible = false;
      });
    }
  }


  void _showDateToast(String message) {
    Fluttertoast.cancel();
    
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.green.shade400,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가계부'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      endDrawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          Container(
            color: Colors.grey[200],
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_left),
                  onPressed: () {
                    setState(() {
                      year = year - 1;
                      _fetchTransactions();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () {
                    setState(() {
                      month = month - 1;
                      if(month == 0) {
                        month = 12;
                        year = year - 1;
                      }
                      _fetchTransactions();
                    });
                  },
                ),
                GestureDetector(
                  child: Text(' $year 년 $month 월'),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      month = month + 1;
                      if(month == 13) {
                        month = 1;
                        year = year + 1;
                      }
                      _fetchTransactions();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  onPressed: () {
                    setState(() {
                      year = year + 1;
                      _fetchTransactions();
                    });
                  },
                ),
              ],
            ),
          ),
          if (transactions.isNotEmpty) 
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                MoneyTransaction transaction = transactions[index];
                if (!filterValue.contains(transactions[index].categoryType)) {
                  return const SizedBox.shrink();
                }
                final isSelected = selectedIds.contains(transaction.id);
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: transaction.categoryType == '소비' ? [Colors.red.shade200, Colors.red.shade50] : transaction.categoryType == '수입' ? [Colors.blue.shade200, Colors.blue.shade50] : [Colors.grey.shade200, Colors.grey.shade50],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    title: Text(transaction.goods),
                    subtitle: Text(transaction.category),
                    trailing: Text(formatterK(transaction.categoryType == '소비' ? transaction.amount * -1 : transaction.amount), style: TextStyle(fontSize: 20, color: transaction.categoryType == '소비' && transaction.amount > 0 ? Colors.grey : Colors.black)),// 여기에 거래와 관련된 추가 정보 표시할 수 있음
                    leading: isSelectionMode
                    ? Icon(
                      isSelected ? Icons.check : null,
                      color: isSelected ? Colors.green : Colors.transparent,
                    )
                    : null,
                    onTap: isSelectionMode
                      ? () => toggleSelection(transaction.id!)
                      : () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => BookAdd(moneyTransaction: transactions[index]),
                            transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        ).then((result) {
                          setState(() {
                            _fetchTransactions();
                          });
                        }
                      );
                    },
                    onLongPress: () {
                      enterSelectionMode();
                      toggleSelection(transaction.id!);
                    }
                  ),
                );
              },
            ),
          ),
          if (transactions.isEmpty)
          const Center(child: Text('금월 데이터가 없습니다')),
        ]
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'filter-floating',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('내역 필터'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<String>(
                              value: '기본',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('기본'),
                              subtitle: const Text('소비 + 수입'),
                            ),
                            RadioListTile<String>(
                              value: '소비',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('소비'),
                              subtitle: const Text(
                                  '소비 내역만'),
                            ),
                            RadioListTile<String>(
                              value: '수입',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('수입'),
                              subtitle: const Text(
                                  '수입 내역만'),
                            ),
                            RadioListTile<String>(
                              value: '전체',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('전체'),
                              subtitle: const Text(
                                  '소비 + 수입 + 이체'),
                            ),
                          ],
                        );
                      },
                    ),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소'),
                        ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              switch (transactionFilter) {
                                case '기본' :
                                  filterValue = ['소비', '수입'];
                                  break;
                                case '소비' :
                                  filterValue = ['소비'];
                                  break;
                                case '수입' :
                                  filterValue = ['수입'];
                                  break;
                                case '전체' :
                                  filterValue = ['소비', '수입', '이체'];
                                  break;
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('확인'),
                        ),
                    ],
                  );
                },
              );
            },
            tooltip: '표시 내역 필터',
            child: transactionFilter == '기본' ? const Icon(Icons.filter_alt_outlined) : const Icon(Icons.filter_alt),
          ),
          const SizedBox(height: 8.0),
          Visibility(
            visible: _isVisible,
            child:  FloatingActionButton(
              heroTag: 'ADD-floating',
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const BookAdd(),
                    transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                ).then((result) {
                  setState(() {
                    _fetchTransactions();
                  });
                });
              },
              tooltip: '기록 데이터 추가',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  void showTileAdminButton() {
    bottomButtonController = showBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               SizedBox (
                width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
                  onPressed: exitSelectionMode,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('취소'),
                ),
              ),
              SizedBox (
                width: MediaQuery.of(context).size.width * 0.3,
                child:ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('삭제 확인'),
                          content: const Text('데이터를 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteDatasFromDatabase();
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text('삭제'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('삭제', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
      enableDrag: false,
    );
  }

  void deleteDatasFromDatabase() {
    for (var id in selectedIds) {
      DatabaseAdmin().deleteMoneyTransaction(id);
    }

    setState(() {
      transactions.removeWhere((transaction) => selectedIds.contains(transaction.id));
      selectedIds.clear();
      isSelectionMode = false;
    });

    bottomButtonController?.close();
  }

  
  void toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
    if (selectedIds.isEmpty) exitSelectionMode();
  }

  void enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
    showTileAdminButton();
  }

  void exitSelectionMode() {
    setState(() {
      selectedIds.clear();
      isSelectionMode = false;
    });
    bottomButtonController?.close(); // Close the bottom sheet
  }
}