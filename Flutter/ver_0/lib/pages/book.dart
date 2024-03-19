import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  // DateTime StartDate = DateTime.now();
  // DateTime EndDate = DateTime.now();


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
                        return ListTile(
                          title: Text(transaction.goods),
                          subtitle: Text(transaction.amount.toString()),// 여기에 거래와 관련된 추가 정보 표시할 수 있음
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookAdd(moneyTransaction: transactions[index]),
                              ),
                            ).then((result) {
                              setState(() {});
                            });
                          }, 
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
            MaterialPageRoute(builder: (context) => const BookAdd()),
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