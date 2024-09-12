import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
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
  bool _isVisible = true; // 플로팅 버튼이 보이는지 여부를 나타내는 변수
  int initialFilterState = 0;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  List<MoneyTransaction> transactions = [];

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
    setState(() {
      transactions = fetchedTransactions;
    });
  }

  String formatterK(num number) {
    late String fString;
    late String addon;
    if(number.toString().contains('.')) {
      fString = number.toString().split('.')[0];
      addon = ".${number.toString().split('.')[1]}";
    } else {
      fString = number.toString();
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
      setState(() {
        _isVisible = true;
      });
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() {
        _isVisible = false;
      });
    }
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
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: transaction.amount > 0 ? [Colors.red.shade200, Colors.red.shade50] : [Colors.blue.shade200, Colors.blue.shade50],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  child: ListTile(
                    title: Text(transaction.goods),
                    subtitle: Text(transaction.category),
                    trailing: Text(formatterK(transaction.amount.abs()), style: const TextStyle(fontSize: 20)),// 여기에 거래와 관련된 추가 정보 표시할 수 있음
                    onTap: () {
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
                      });
                    }, 
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
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: '기록 데이터 추가',
            child: initialFilterState == 0 ? const Icon(Icons.filter_alt_outlined) : const Icon(Icons.filter_alt),
          ),
          const SizedBox(height: 8.0),
          Visibility(
            visible: _isVisible,
            child:  FloatingActionButton(
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
}