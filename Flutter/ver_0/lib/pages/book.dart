import 'package:flutter/material.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/money_transaction.dart';
import 'package:ver_0/pages/book_add.dart';

class Book extends StatefulWidget {
  const Book({super.key});
  
  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  int year = DateTime.now().year;
  int month = DateTime.now().month;

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
                    });
                    // 이전 월로 이동하는 로직
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
                    });
                    // 이전 월로 이동하는 로직
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
                    });
                    // 다음 월로 이동하는 로직
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_double_arrow_right),
                  onPressed: () {
                    setState(() {
                      year = year + 1;
                    });
                    // 다음 월로 이동하는 로직
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MoneyTransaction>>( // 변경된 FutureBuilder
              future: DatabaseAdmin().getTransactionsByMonth(year, month), // 현재 연도와 월에 해당하는 거래 가져오기
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<MoneyTransaction>? transactions = snapshot.data;
                  if (transactions != null && transactions.isNotEmpty) {
                    return ListView.builder(
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
                                setState(() {});
                              });
                            }, 
                          ),
                        );
                      },
                    );
                  } else {
                  return const Center(child: Text('금월 데이터가 없습니다'));
                  }
                }
              },
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
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
            setState(() {});
          });
        },
        tooltip: '기록 데이터 추가',
        child: const Icon(Icons.add),
      ),//
    );
  }
}