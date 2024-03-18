import 'package:flutter/material.dart';
import 'package:ver_0/pages/investment_add.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/current_holdings.dart';
import 'package:ver_0/widgets/models/expiration_investment.dart';
import 'package:ver_0/widgets/models/nonexpiration_investment.dart';

class Invest extends StatelessWidget {
  const Invest({super.key});

  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 수를 지정합니다. 여기서는 두 개의 탭이 있으므로 2로 설정합니다.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('투자정보'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        endDrawer: const AppDrawer(),
        body: const Column(
          children: [
            TabBar(
              tabs: <Widget>[
                Tab(text: '투자 상태'),
                Tab(text: '리스트'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Center(child: InvestHolingsPage()),
                  Center(child: InvestListPage()),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvestAdd()),
            );
          },
          tooltip: '투자 정보 추가',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class InvestHolingsPage extends StatefulWidget {
  const InvestHolingsPage({super.key});

  @override
  State<InvestHolingsPage> createState() => _InvestHolingsPageState();
}

class _InvestHolingsPageState extends State<InvestHolingsPage> {
    List<Holdings> currentHoldings = [];
    List<String> investCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchHoldings();
  }
  
  Future<void> _fetchHoldings() async {
    List<Holdings> fetchedHoldings = await DatabaseAdmin().getCurrentHoldInvestments();
    setState(() {
      currentHoldings = fetchedHoldings;
      investCategories = currentHoldings.map((holding) => holding.investcategory).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    Map<String, List<Holdings>> groupedHoldings = {};
    for (var holding in currentHoldings) {
      if (!groupedHoldings.containsKey(holding.investcategory)) {
        groupedHoldings[holding.investcategory] = [];
      }
      groupedHoldings[holding.investcategory]!.add(holding);
    }

    if (currentHoldings.isEmpty) {
      return const Center(
        child: Text(
          '투자 데이터가 없습니다',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView(
      children: groupedHoldings.entries.map((entry) {
        String category = entry.key;
        List<Holdings> holdings = entry.value;

        // 카테고리별 보유 정보 리스트를 출력하는 위젯을 생성합니다.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                category, // 카테고리 이름 출력
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: holdings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(holdings[index].investment),
                  subtitle: Text(holdings[index].totalAmount.toString()),
                );
              },
            ), 
          ],
        );
      }).toList(),
    );
  }
}

class InvestListPage extends StatefulWidget {
  const InvestListPage({super.key});

  @override
  State<InvestListPage> createState() => _InvestListPageState();
}

class _InvestListPageState extends State<InvestListPage> {
  List<ExpirationInvestment> expirationInvestments = [];
  List<NonexpirationInvestment> nonexpirationInvestments = [];
  DateTime endDate = DateTime.now().add(const Duration(days: 10));
  DateTime startDate = DateTime.now().subtract(const Duration(days: 10));

  @override
  void initState() {
    super.initState();
    _fetchInvestments();
  }

  Future<void> _fetchInvestments() async {
    List<ExpirationInvestment> fetchedexpirationInvestments = await DatabaseAdmin().getExInvestmentsByDateRange(startDate, endDate);
    List<NonexpirationInvestment> fetchednonexpirationInvestments = await DatabaseAdmin().getNonExInvestmentsByDateRange(startDate, endDate);
    setState(() {
      expirationInvestments = fetchedexpirationInvestments;
      nonexpirationInvestments = fetchednonexpirationInvestments;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:[
          // Container(
          //   color: Colors.grey[200],
          //   child:Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       IconButton(
          //         icon: const Icon(Icons.keyboard_double_arrow_left),
          //         onPressed: () {
          //           setState(() {
          //             year = year - 1;
          //           });
          //           // 이전 월로 이동하는 로직
          //         },
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.arrow_back_ios_new),
          //         onPressed: () {
          //           setState(() {
          //             month = month - 1;
          //             if(month == 0) {
          //               month = 12;
          //               year = year - 1;
          //             }
          //           });
          //           // 이전 월로 이동하는 로직
          //         },
          //       ),
          //       GestureDetector(
          //         child: Text(' $year 년 $month 월'),
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.arrow_forward_ios),
          //         onPressed: () {
          //           setState(() {
          //             month = month + 1;
          //             if(month == 13) {
          //               month = 1;
          //               year = year + 1;
          //             }
          //           });
          //           // 다음 월로 이동하는 로직
          //         },
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.keyboard_double_arrow_right),
          //         onPressed: () {
          //           setState(() {
          //             year = year + 1;
          //           });
          //           // 다음 월로 이동하는 로직
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          Container(),
          Expanded(
            child: FutureBuilder<List<ExpirationInvestment>>( // 변경된 FutureBuilder
              future: DatabaseAdmin().getExInvestmentsByDateRange(startDate, endDate), // 현재 연도와 월에 해당하는 거래 가져오기
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<ExpirationInvestment>? transactions = snapshot.data;
                  if (transactions != null && transactions.isNotEmpty) {
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        ExpirationInvestment transaction = transactions[index];
                        return ListTile(
                          title: Text(transaction.investment),
                          subtitle: Text(transaction.amount.toString()),// 여기에 거래와 관련된 추가 정보 표시할 수 있음
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InvestAdd(expirationInvestment: transactions[index]),
                              ),
                            );
                          }, 
                        );
                      },
                    );
                  } else {
                  return const Center(child: Text('해당기간 투자 데이터가 없습니다'));
                  }
                }
              },
            ),
          ),
        ]
      );
  }
}