// import 'dart:convert';
// import 'dart:async';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import 'package:syncfusion_flutter_core/core.dart';
import 'package:ver_0_2/pages/book.dart';
// import 'package:ver_0_2/pages/investment.dart';
import 'package:ver_0_2/pages/stats.dart';
import 'package:ver_0_2/widgets/tab_bar.dart';
import 'package:ver_0_2/widgets/drawer_end.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/synchro_charts_etc.dart';
import 'package:ver_0_2/widgets/synchro_pie_charts.dart';
import 'package:ver_0_2/widgets/models/budget_setting.dart';
import 'package:ver_0_2/colorsholo.dart';
// import 'package:ver_0_2/widgets/models/current_holdings.dart';

void main() {
  // SyncfusionLicense.registerLicense("YOUR LICENSE KEY"); 
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: HoloColors.ceresFauna),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 탭별로 표시될 위젯을 리스트로 관리
  final List<Widget> _pages = [
    // const Page(), // 필요할 경우 주석 해제
    const HomePageCotent(),
    const Book(),
    // const Invest(),
    const StatisticsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    // Widget selectedWidget = const HomePageCotent();
    // switch (_selectedIndex) {
    //   case 0:
    //     selectedWidget = const HomePageCotent();
    //     break;
    //   case 1:
    //     selectedWidget = const Book();
    //     break;
    //   // case 2:
    //   //   selectedWidget = const Invest();
    //   //   break;
    //   case 2:
    //     selectedWidget = const StatisticsView();
    //     break;
    // }
    
    Widget selectedWidget = _pages[_selectedIndex];

    return Scaffold(
      body: selectedWidget,
      bottomNavigationBar: AppBottomNavBar(
        onItemSelected: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}

class HomePageCotent extends StatefulWidget {
  const HomePageCotent({super.key});

  @override
  State<HomePageCotent> createState() => _HomePageCotentState();
}

class _HomePageCotentState extends State<HomePageCotent> {
  final TextEditingController _textFieldSavingController = TextEditingController();
  final TextEditingController _textFieldIncomeController = TextEditingController();
  final TextEditingController _textFieldInputController = TextEditingController();
  int? income;
  int? incomeId;
  bool isloading = true;
  int yearnow = DateTime.now().year;
  int monthnow = DateTime.now().month;
  List<BudgetSetting> budgetSet = [];
  List<Map<String, dynamic>>expenseData= [];
  double totalExpenseAmount= 0;
  bool isPercentageChannels = true;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    _fetchDatas().then((_) {
      if (budgetSet.isEmpty) {
        try {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setInitialSaving();
          });
        } catch (e) {
          logger.e(e);
        }
      }
    });
  }
  Future<void> _fetchDatas() async {
    isloading = true;
    double localTotalExpenseAmount= 0;
    List<BudgetSetting> fetchedBudgetSet = await DatabaseAdmin().getMonthBugetList(yearnow, monthnow);
    List<Map<String, dynamic>> fetchedExpenseData =  await DatabaseAdmin().getTransactionsSUMByCategoryandDate(yearnow,monthnow);
    List<Map<String, dynamic>> localexpenseData = [...fetchedExpenseData];
    Map<String, dynamic> localIncomeData = await DatabaseAdmin().getIncome();

    localexpenseData.sort((previous, next) => next['totalAmount'].compareTo(previous['totalAmount']));
    for (var data in localexpenseData) {
      localTotalExpenseAmount = localTotalExpenseAmount + data['totalAmount'];
    }
    if (mounted) {
      setState(() {
        expenseData = fetchedExpenseData;
        budgetSet = fetchedBudgetSet;
        totalExpenseAmount = localTotalExpenseAmount;
        isloading = false;
        if (localIncomeData.isNotEmpty) {
          incomeId = localIncomeData['id'];
          income = localIncomeData['income'];
        }
      });
      // logger.d(budgetSet);
      // if (budgetSet.isEmpty) {
      //   setInitialSaving();
      // }
      // logger.d(budgetCategoryData) ;   
      // logger.d(budgetSet[0].budgetList) ;   
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the HomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Junior Demo App (Book Account)'),
        ),
        endDrawer: const AppDrawer(),
        body: SafeArea(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child:  
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const Text("미예정"),
                Expanded(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height*0.9,
                      autoPlay: true,
                      viewportFraction: 0.9,
                      autoPlayInterval: const Duration(seconds: 3),
                    ),
                    items: [1,2,3].map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          switch (i) {
                            case 1:
                              if (budgetSet.isEmpty || income == null) {
                                return Stack(
                                  children: [ 
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("최근 3개월 소득",style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                          Expanded(
                                            child: StackChartsMainpage(
                                              range: 3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.zoom_out_map),
                                        color: Colors.grey,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) => const LandScapeStackChartMain(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              } else{
                                return const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("이번달 소득과 소비 현황",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: BudgetMainPagePieChart(),
                                    )
                                  ],
                                );
                              }
                            case 2:
                              return Stack(
                                children: [ 
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: 
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("최근 3개월 소득",style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),),
                                      Expanded(
                                    child: StackChartsMainpage(
                                        range: 3,
                                      // onPieDoubleSelected: (ChartPointDetails pointInteractionDetails) {
                                      //   Navigator.push(
                                      //     context,
                                      //     PageRouteBuilder(
                                      //       pageBuilder: (context, animation, secondaryAnimation) => const LandScapeStackChartMain(),
                                      //     ),
                                      //   );
                                      // },
                                        ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.zoom_out_map),
                                      color: Colors.grey,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => const LandScapeStackChartMain(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            case 3:
                              return Stack(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "최근 3개월 순소득",
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: ComboChartsMainpage(range: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.zoom_out_map),
                                      color: Colors.grey,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => const LandScapeComboChartMain(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      );
                    }).toList(),
                  ),
                      // OutlinedButton(
                      //   onPressed: (){
                      //     DatabaseAdmin().clearExtraGroup();
                      //   }, 
                      //   child: Text('칟ㅁㄱ ㄷㅌㅅㄱㅁ')
                      // )
                      // InvestHolingsPage(currentHoldings: currentHoldings, investCategories: investCategories),
                    // ],
                )
              ],
            )
        ),
      );
    }
  }


  void setInitialSaving() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('목표 저축 금액을 입력해주세요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textFieldSavingController,
                cursorColor: Colors.transparent,
                keyboardType: TextInputType.number, // 숫자만 입력하도록 지정
                decoration: const InputDecoration(
                  hintText: '목표 저축액을 입력하세요', // 힌트 텍스트
                ),
              ),              
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(' 만원', textAlign: TextAlign.left, style: TextStyle(fontSize: 20),),
                ],
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
                Navigator.pop(context);
                if(income == null) {
                  setInitialIncome();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text('이전에 입력한 수입 금액 기준으로 예산을 설정합니까?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setInitialIncome();
                          },
                          child: const Text('아니오'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              if (income != null) {
                                int budget = income! - int.parse(_textFieldSavingController.text);
                                insertNewBudgetToDatabase(budget);
                                _fetchDatas();
                              }
                            });
                          },
                          child: const Text('예'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('입력'),
            ),
          ],
        );
      },
    );
  }

  void setInitialIncome() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('예상 수입 혹은 용돈 금액을 입력해주세요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textFieldIncomeController,
                cursorColor: Colors.transparent,
                keyboardType: TextInputType.number, // 숫자만 입력하도록 지정
                decoration: const InputDecoration(
                  hintText: '수입 금액을 입력하세요', // 힌트 텍스트
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(' 만원', textAlign: TextAlign.left, style: TextStyle(fontSize: 20),),
                ],
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
                  income = int.parse(_textFieldIncomeController.text);
                  if (income != null) {
                    int budget = income! - int.parse(_textFieldSavingController.text);
                    insertincomeToDatabase(int.parse(_textFieldIncomeController.text));
                    insertNewBudgetToDatabase(budget);
                    _fetchDatas();
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('입력'),
            ),
          ],
        );
      },
    );
  }

  void insertNewBudgetToDatabase(int budget) {
    _textFieldInputController.text = (budget * 10000).toString(); 
    final BudgetSetting newBudget = BudgetSetting(
      year : yearnow,
      month : monthnow, 
      budgetList: <String,double>{"총 예산": double.parse(_textFieldInputController.text)},
    );

    DatabaseAdmin().insertBugetSettingTable(newBudget);
  }

  void insertincomeToDatabase(int income) {
    _textFieldInputController.text = (income * 10000).toString();
    if (incomeId == null) {
      DatabaseAdmin().insertIncomeTable(int.parse(_textFieldInputController.text));
    } else {
      DatabaseAdmin().updateIncomeTable(int.parse(_textFieldInputController.text), incomeId!);
    }
  }
}

///메인스택차트 확장 페이지
class LandScapeStackChartMain extends StatefulWidget {
  const LandScapeStackChartMain({super.key});

  @override
  State<LandScapeStackChartMain> createState() => _LandScapeStackChartMainState();
}

class _LandScapeStackChartMainState extends State<LandScapeStackChartMain> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    isLoading = false;
  }

  @override
  void dispose() {
    isLoading = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading 
      ? const Center(child: CircularProgressIndicator())
      : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width*0.9,
            height: MediaQuery.of(context).size.height*0.9,
            child: const StackChartsMainpage(),
          ),
        ) 
      ),
    );
  }
}

///메인콤보차트 확장 페이지
class LandScapeComboChartMain extends StatefulWidget {
  const LandScapeComboChartMain({super.key});

  @override
  State<LandScapeComboChartMain> createState() => _LandScapeComboChartMainState();
}

class _LandScapeComboChartMainState extends State<LandScapeComboChartMain> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    isLoading = false;
  }

  @override
  void dispose() {
    isLoading = true;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading 
      ? const Center(child: CircularProgressIndicator())
      : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const ComboChartsMainpage(),
          ),
        ),
      ),
    );
  }
}

// class InvestHolingsPage extends StatelessWidget {
//   final List<Holdings> currentHoldings;
//   final List<String> investCategories;
//   const InvestHolingsPage({required this.currentHoldings, required this.investCategories, super.key});

//   @override
//   Widget build(BuildContext context) {

//     Map<String, List<Holdings>> groupedHoldings = {};
//     for (var holding in currentHoldings) {
//       if (!groupedHoldings.containsKey(holding.investcategory)) {
//         groupedHoldings[holding.investcategory] = [];
//       }
//       groupedHoldings[holding.investcategory]!.add(holding);
//     }

//     if (currentHoldings.isEmpty) {
//       return const Center(
//         child: Text(
//           '투자 데이터가 없습니다',
//           style: TextStyle(fontSize: 18),
//         ),
//       );
//     }

//     return ListView(
//       children: groupedHoldings.entries.map((entry) {
//         String category = entry.key;
//         List<Holdings> holdings = entry.value;

//         // 카테고리별 보유 정보 리스트를 출력하는 위젯을 생성합니다.
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 category, // 카테고리 이름 출력
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: holdings.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(holdings[index].investment),
//                   subtitle: Text(holdings[index].totalAmount.toString()),
//                 );
//               },
//             ), 
//           ],
//         );
//       }).toList(),
//     );
//   }
// }
