import 'package:flutter/material.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/money_transaction.dart';
import 'package:ver_0/pages/book_add.dart';

class Book extends StatelessWidget {
  const Book({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('가계부'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Handle info button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              // Handle help button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
          )
        ],
      ),
      endDrawer: const AppDrawer(),
      body: FutureBuilder<List<MoneyTransaction>>( // 변경된 FutureBuilder
        future: DatabaseAdmin().getTransactionsByMonth(DateTime.now().year, DateTime.now().month), // 현재 연도와 월에 해당하는 거래 가져오기
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
                      );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookAdd()),
          );
        },
        tooltip: '기록 데이터 추가',
        child: const Icon(Icons.add),
      ),//
    );
  }
}