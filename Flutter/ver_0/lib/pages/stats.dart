import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:logger/logger.dart';
import 'package:ver_0/widgets/drawer_end.dart';
import 'package:ver_0/widgets/bar_charts.dart';
import 'package:ver_0/widgets/linerar_gauge.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/current_holdings.dart';
import 'package:ver_0/widgets/models/budget_setting.dart';
import 'package:ver_0/widgets/models/transaction_category.dart';


class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('통계'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        endDrawer: const AppDrawer(),
        body: const Column(
          children: [
            TabBar(
              tabs: <Widget>[
                Tab(text: '가계부'),
                Tab(text: '자산관리'),
              ]
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  NestedTabBarBook(),
                  NestedTabBarInvest(),
                ],
              ),
            )
          ]
        ),
      ),
    );
  }
}

///월간 이동 바
class DateMonthBar extends StatefulWidget {
  final int year;
  final int month;
  final Function() yearBack;
  final Function() monthBack;
  final Function() yearForward;
  final Function() monthForward;
  const DateMonthBar({
    required this.year,
    required this.month,
    required this.yearBack,
    required this.monthBack,
    required this.yearForward,
    required this.monthForward,
    super.key
  });

  @override
  State<DateMonthBar> createState() => _DateMonthBarState();
}

class _DateMonthBarState extends State<DateMonthBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_left),
            onPressed: widget.yearBack,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: widget.monthBack,
          ),
          GestureDetector(
            child: Text(' ${widget.year} 년 ${widget.month} 월'),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: (widget.year >= DateTime.now().year && widget.month >= DateTime.now().month) ?  null :
            widget.monthForward,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_double_arrow_right),
            onPressed: (widget.year >= DateTime.now().year) ? null :
            widget.yearForward,
          ),
        ],
      ),
    );
  }
}

class NestedTabBarBook extends StatefulWidget {
  const NestedTabBarBook({super.key});

  @override
  State<NestedTabBarBook> createState() => _NestedTabBarBookState();
}

class _NestedTabBarBookState extends State<NestedTabBarBook> with SingleTickerProviderStateMixin {
  Logger logger = Logger();
  final PageController _pageController = PageController();
  int currentIndex = 0;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int pastyear = DateTime.now().year;
  int pastmonth = DateTime.now().month;
  bool isyearcompare = false;
  String selectCategory = "";

  @override
  void initState() {
    super.initState();
    setPastDate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void setPastDate(){
    setState(() {
      if(isyearcompare) {
          pastyear = year-1;
          pastmonth = month;
      } else {
        if (month == 1) {
          pastyear = year-1;
          pastmonth = 12;
        } else {
          pastyear = year;
          pastmonth = month-1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: const <Widget>[
                Tab(text: '한달 소비'),
                Tab(text: '예산 상태'),
                Tab(text: '특별 예산'),
              ],
              onTap: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            if (currentIndex < 2) 
            Column(
              children: [
                DateMonthBar(
                  year: year,
                  month: month,
                  yearBack: () {
                    setState(() {
                      year = year - 1;
                      setPastDate();
                      selectCategory = "";
                    });
                  },
                  monthBack: () {
                    setState(() {
                      month = month - 1;
                      if(month == 0) {
                        month = 12;
                        year = year - 1;
                      }
                      setPastDate();
                      selectCategory = "";
                    });
                  },
                  monthForward: () {
                    setState(() {
                      month = month + 1;
                      if(month == 13) {
                        month = 1;
                        year = year + 1;
                      }
                      setPastDate();
                      selectCategory = "";
                    });
                  },
                  yearForward: () {
                    setState(() {
                      year = year + 1;
                      setPastDate();
                      selectCategory = "";
                    });
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    children: [
                      ///그래프 포함 컬럼
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(!isyearcompare)
                              const Text('월간',style: TextStyle(fontSize: 20),),
                              if(isyearcompare)
                              const Text('연간',style: TextStyle(fontSize: 20),),
                              const SizedBox(width: 5,),
                              Switch.adaptive(
                                value: isyearcompare,
                                activeColor: Colors.teal,
                                activeTrackColor: Colors.teal.shade200,
                                inactiveThumbColor: Colors.teal,
                                inactiveTrackColor: Colors.teal.shade200,
                                onChanged: (bool value) {
                                  setState(() {
                                    isyearcompare = value;
                                    setPastDate();
                                    selectCategory = "";
                                  });
                                },
                              ),
                              const SizedBox(width: 20,),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$year-${month.toString().padLeft(2, '0')}',style: const TextStyle(fontSize: 20),),
                              const Text('  vs  ',style: TextStyle(fontSize: 20),),
                              Text('$pastyear-${pastmonth.toString().padLeft(2, '0')}',style: const TextStyle(fontSize: 20),),
                            ],
                          ),
                          const SizedBox(height: 50),
                          Expanded(
                            child: ColumnChartsByCategoryMonth(
                              key: UniqueKey(),
                              year: year,
                              month: month,
                              pastyear: pastyear,
                              pastmonth: pastmonth,
                              onBarSelected: (ChartPointDetails pointInteractionDetails) {
                                logger.i(pointInteractionDetails);
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                                if(pointInteractionDetails.dataPoints != null) {
                                  var detailList = pointInteractionDetails.dataPoints;
                                  if (pointInteractionDetails.pointIndex != null) {
                                    setState(() {
                                      selectCategory = detailList![pointInteractionDetails.pointIndex!].x;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                      if(selectCategory != "")
                      Column(
                        children: [
                          Expanded(
                            child: BarchartGoodsInCategories(
                              key: UniqueKey(),
                              year: year,
                              month: month,
                              category: selectCategory
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      BudgetSettingPage(key: UniqueKey(), year: year, month: month,),
                    ],
                  ),
                  BarChartSample2(),
                ],
              ),
            )
          ]
        ),
      ),
    );
  }
}

///예산 페이지
class BudgetSettingPage extends StatefulWidget {
  final int year;
  final int month;
  const BudgetSettingPage({required this.year, required this.month, super.key});

  @override
  State<BudgetSettingPage> createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends State<BudgetSettingPage> {
  Logger logger = Logger();
  bool isflipover = true;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _categoryFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          DatabaseAdmin().getMonthBugetList(widget.year, widget.month),
          DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.year,widget.month),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<BudgetSetting> fetchedBudgetSet = snapshot.data?[0] ?? [];
            List<Map<String, dynamic>> fetchedExpenseData = snapshot.data?[1] ?? [];
            if (fetchedBudgetSet.isEmpty) {
              return emptyBudgetWidget();
            }
            double totalExpenseAmount= 0;
            List<String> categoryData = [];
            List<String> budgetCategoryData = [];
            List<Map<String, dynamic>> localexpenseData = [...fetchedExpenseData];
            if (fetchedBudgetSet.isNotEmpty && fetchedBudgetSet[0].budgetList != null) {
              for (var key in fetchedBudgetSet[0].budgetList!.keys) {
                categoryData.add(key);
                budgetCategoryData.add(key);
              }
            }
            localexpenseData.sort((previous, next) => next['totalAmount'].compareTo(previous['totalAmount']));
            for (var data in localexpenseData) {
              categoryData.add(data['category']);
              totalExpenseAmount = totalExpenseAmount + data['totalAmount'];
            }
            categoryData = categoryData.toSet().toList();
            categoryData.remove('총 예산');
            budgetCategoryData.remove('총 예산');
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('예산 총액', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  const SizedBox(height: 30),
                  PercentageGaugeBar(childNumber: totalExpenseAmount,motherNumber: fetchedBudgetSet[0].budgetList!['총 예산']!),
                  const Divider(height: 50),
                  Align(
                    alignment: const Alignment(0.8,0.5),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isflipover = !isflipover;
                        });
                      },
                      icon: const Icon(Icons.autorenew),
                    )
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(microseconds: 450),
                    reverseDuration: const Duration(microseconds: 450),
                    switchInCurve: Curves.ease,
                    switchOutCurve: Curves.easeIn,
                    // transitionBuilder: transition,
                    child: isflipover ? 
                    // Column(
                    //   children:
                      // [
                        percetageChanel(fetchedBudgetSet, fetchedExpenseData, categoryData)
                        // ]
                    // )
                    : 
                    // Column(
                    //   children:
                      // [
                        budgetChanel(fetchedBudgetSet, budgetCategoryData)
                        // ]
                    // ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
  Widget emptyBudgetWidget() {
    return Center(
      child: SizedBox(
        width: 300,
        height: 100,
        child: FilledButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('${widget.year}년 ${widget.month}월 예산 등록'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('총 예산: ', textAlign: TextAlign.left,),
                        ],
                      ),
                      TextField(
                        controller: _textFieldController,
                        cursorColor: Colors.transparent,
                        keyboardType: TextInputType.number, // 숫자만 입력하도록 지정
                        decoration: const InputDecoration(
                          hintText: '예산을 입력하세요', // 힌트 텍스트
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          insertNewBudgetToDatabase();
                          _textFieldController.clear();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('등록'),
                    ),
                  ],
                );
              },
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
          ),
          child: const Text('예산 등록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),),
        )
      ), 
    );
  }

  Widget percetageChanel(List<BudgetSetting> budgetSet, List<Map<String, dynamic>> expenseData, List<String> categoryData) {
    return ListView.builder(
      key: const Key('percentage'),
      shrinkWrap: true,
      itemCount: categoryData.length,
      itemBuilder: (context, index) {
        final key = categoryData[index];
        final valueA = budgetSet[0].budgetList![key] ?? 0.0;
        final valueB =
            expenseData.firstWhere((map) => map['category'] == key, orElse: () => {'totalAmount': 0.0})['totalAmount'];
        return Padding(
          padding: const EdgeInsets.all(12),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: Text(key, style: const TextStyle(fontSize: 24)),
              ),
              Expanded(
                flex: 4,
                child: PercentageGaugeBar(childNumber: valueB,motherNumber: valueA, isThick: false)
              )
            ]
          ),
        );
      },
    );
  }

  Widget budgetChanel(List<BudgetSetting> budgetSet, List<String> budgetCategoryData) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('${widget.year}년 ${widget.month}월 예산 등록'),
                    content:  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                readOnly: true,
                                controller: _categoryFieldController,
                                decoration: const InputDecoration(suffixIcon: Icon(Icons.arrow_drop_down)),
                                onTap: () {
                                  _showCategoryModal(context);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                controller: _textFieldController,
                                cursorColor: Colors.transparent,
                                keyboardType: TextInputType.number, // 숫자만 입력하도록 지정
                                decoration: const InputDecoration(
                                  hintText: '예산을 입력하세요', // 힌트 텍스트
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _textFieldController.clear();
                            _categoryFieldController.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if(budgetSet[0].budgetList != null) {
                              updateNewBudgetToDatabase(_categoryFieldController.text, double.parse(_textFieldController.text), budgetSet[0].budgetList!);
                              _textFieldController.clear();
                              _categoryFieldController.clear();
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('등록'),
                      ),
                    ],
                  );
                },
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Icon(Icons.add_circle_outline, size:40),
               SizedBox(width: 12),
               Text('항목 예산 등록', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),),
              ],
            ) ,
          )
        ), 
        ListView.builder(
          key: const Key('budget'),
          shrinkWrap: true,
          itemCount: budgetCategoryData.length,
          itemBuilder: (context, index) {
            final key = budgetCategoryData[index];
            final value = budgetSet[0].budgetList![key] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(key, style: const TextStyle(fontSize: 24)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(value.toString(), style: const TextStyle(fontSize: 24)),
                  ),
                ],
              )
            );
          },
        )
      ],
    );
  }

  Widget transition(Widget widget, Animation<double> animation){
    final flipAnimation = Tween(begin: pi, end: 0.0).animate(animation);
    final isUnder = (ValueKey(isflipover)!= widget.key);
    final value = isUnder ? min(flipAnimation.value, pi/2) : flipAnimation.value;
    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, widget) {
        return Transform(
          transform: Matrix4.rotationY(value),
          alignment: Alignment.center,
          child: widget,
        );
      },
      child: widget,
    );
  }

  void insertNewBudgetToDatabase() {
    final BudgetSetting newBudget = BudgetSetting(
      year : widget.year,
      month : widget.month, 
      budgetList: <String,double>{"총 예산": double.parse(_textFieldController.text)},
    );

    DatabaseAdmin().insertBugetSettingTable(newBudget);
  }

  void updateNewBudgetToDatabase(String category, double value, Map<String, double> budgetlist) {
    final Map<String, double>  updatedBudgetList = Map.from(budgetlist);

    updatedBudgetList[category] = value;

    DatabaseAdmin().updateBugetSettingTable(widget.year, widget.month, updatedBudgetList);
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<TransactionCategory>>(
          future: DatabaseAdmin().getAllTransactionCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 데이터 로딩 중이면 로딩 인디케이터 표시
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            List<TransactionCategory> fetchedCategorys = snapshot.data!;
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3), // 원하는 최대 높이로 설정
              child:SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      ...fetchedCategorys.expand((category) {
                      if (category.name == '소비') {
                        return category.itemList!.map((item) {
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              setState(() {
                                _categoryFieldController.text = item;
                                Navigator.pop(context);
                              });
                            },
                          );
                        }).toList();
                      } else {
                        return [];
                      }
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class NestedTabBarInvest extends StatefulWidget {
  const NestedTabBarInvest({super.key});

  @override
  State<NestedTabBarInvest> createState() => _NestedTabBarInvestState();
}

class _NestedTabBarInvestState extends State<NestedTabBarInvest> {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            const TabBar(
              tabs: <Widget>[
                Tab(text: '현재 투자 목록'),
                Tab(text: '수익률 현황'),
              ]
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  InvestHolingsPage(currentHoldings: currentHoldings, investCategories: investCategories),
                  InvestHolingsPage(currentHoldings: currentHoldings, investCategories: investCategories),
                  // const BarchartHorizontal(),
                ],
              ),
            )
          ]
        ),
      ),
    );
  }
}



class InvestHolingsPage extends StatelessWidget {
  final List<Holdings> currentHoldings;
  final List<String> investCategories;
  const InvestHolingsPage({required this.currentHoldings, required this.investCategories, super.key});

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


