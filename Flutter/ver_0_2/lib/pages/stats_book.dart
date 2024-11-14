import 'dart:math';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/synchro_bar_charts.dart';
import 'package:ver_0_2/widgets/synchro_pie_charts.dart';
import 'package:ver_0_2/widgets/synchro_line_charts.dart';
import 'package:ver_0_2/widgets/linerar_gauge.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/budget_setting.dart';
import 'package:ver_0_2/widgets/models/transaction_category.dart';
import 'package:ver_0_2/widgets/models/extra_budget_group.dart';


Logger logger = Logger ();

///월간 이동 바
class DateMonthBar extends StatefulWidget {
  final int year;
  final int month;
  final Function()? yearBack;
  final Function()? monthBack;
  final Function()? yearForward;
  final Function()? monthForward;
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

///월간 소비 목록
class MonthlyConsumePage extends StatefulWidget {
  final int year;
  final int month;
  const MonthlyConsumePage({required this.year, required this.month, super.key});

  @override
  State<MonthlyConsumePage> createState() => _MonthlyConsumePageState();
}

class _MonthlyConsumePageState extends State<MonthlyConsumePage> {
  final PageController _pageController = PageController();
  int pastyear = DateTime.now().year;
  int pastmonth = DateTime.now().month;
  bool isNotCompareBar = false;
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
      if (widget.month == 1) {
        pastyear = widget.year-1;
        pastmonth = 12;
      } else {
        pastyear = widget.year;
        pastmonth = widget.month-1;
      }
      selectCategory = "";
    });
  }


  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      children: [
        ///그래프 포함 컬럼
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(!isNotCompareBar)
                        const Text('전월 비교',style: TextStyle(fontSize: 20)),
                        if(isNotCompareBar)
                        const Text('비용 비율',style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 5,),
                        Switch.adaptive(
                          value: isNotCompareBar,
                          activeColor: Colors.teal,
                          activeTrackColor: Colors.teal.shade200,
                          inactiveThumbColor: Colors.teal,
                          inactiveTrackColor: Colors.teal.shade200,
                          onChanged: (bool value) {
                            setState(() {
                              isNotCompareBar = value;
                              setPastDate();
                              selectCategory = "";
                            });
                          },
                        ),
                        const SizedBox(width: 20,),
                      ],
                    ),
                    if(!isNotCompareBar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${widget.year}-${widget.month.toString().padLeft(2, '0')}',style: const TextStyle(fontSize: 20),),
                        const Text('  vs  ',style: TextStyle(fontSize: 20),),
                        Text('$pastyear-${pastmonth.toString().padLeft(2, '0')}',style: const TextStyle(fontSize: 20),),
                      ],
                    ),
                  ]
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0), // 오른쪽 마진
                  child: ElevatedButton(
                    onPressed:(){
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => BudgetSettingPage(year: widget.year, month: widget.month),
                            transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
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
                          });
                        }
                      );
                    },
                    child: const  Text('월간 예산\n 설정', textAlign: TextAlign.center,)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            if(!isNotCompareBar)
            Expanded(
              child: ColumnChartsByCategoryMonth(
                key: UniqueKey(),
                year: widget.year,
                month: widget.month,
                pastyear: pastyear,
                pastmonth: pastmonth,
                onBarSelected: (ChartPointDetails pointInteractionDetails) {
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
            if(isNotCompareBar)
            Expanded(
              child: PieChartsByCategoryMonth(
                key: UniqueKey(),
                year: widget.year,
                month: widget.month,
                onPieSelected: (ChartPointDetails pointInteractionDetails) {
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
                year: widget.year,
                month: widget.month,
                category: selectCategory
              ),
            ),
            const SizedBox(height: 50),
          ],
        )
      ],
    );
  }
}

///연간 소비 목록
class YearlyConsumePage extends StatefulWidget {
  final int year;
  const YearlyConsumePage({required this.year, super.key});

  @override
  State<YearlyConsumePage> createState() => _YearlyConsumePageState();
}

class _YearlyConsumePageState extends State<YearlyConsumePage> {
  final PageController _pageController = PageController();
  int pastyear = DateTime.now().year;
  int month = DateTime.now().month;
  bool isNotCompareBar = false;
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
      pastyear = widget.year-1;
      selectCategory = "";
    });
  }


  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     if(!isNotCompareBar)
                    //     const Text('전년 비교',style: TextStyle(fontSize: 20)),
                    //     if(isNotCompareBar)
                    //     const Text('비용 비율',style: TextStyle(fontSize: 20)),
                    //     const SizedBox(width: 5,),
                    //     Switch.adaptive(
                    //       value: isNotCompareBar,
                    //       activeColor: Colors.teal,
                    //       activeTrackColor: Colors.teal.shade200,
                    //       inactiveThumbColor: Colors.teal,
                    //       inactiveTrackColor: Colors.teal.shade200,
                    //       onChanged: (bool value) {
                    //         setState(() {
                    //           isNotCompareBar = value;
                    //           setPastDate();
                    //           selectCategory = "";
                    //         });
                    //       },
                    //     ),
                    //     const SizedBox(width: 20,),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${widget.year}',style: const TextStyle(fontSize: 20),),
                      ],
                    ),
                  ]
                ),
                const Spacer(flex: 1),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0), // 오른쪽 마진
                  child: ElevatedButton(
                    onPressed:(){
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => BudgetSettingYearlyPage(year: widget.year),
                            transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
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
                          });
                        }
                      );
                    },
                    child: const  Text('연간 예산\n 설정', textAlign: TextAlign.center,)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: PieChartsByCategoryYear(
                key: UniqueKey(),
                year: widget.year,
                onPieSelected: (ChartPointDetails pointInteractionDetails) {
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
            // const SizedBox(height: 50),
          ],
        ),
        if(selectCategory != "")
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: LineChartsByYearCategory(
                  key: UniqueKey(),
                  year: widget.year,
                  category: selectCategory
                ),
              ),
              const SizedBox(height: 50),
            ],
          )
        )
      ],
    );
  }
}

///예산 설정 페이지
class BudgetSettingPage extends StatefulWidget {
  final int year;
  final int month;
  const BudgetSettingPage({required this.year, required this.month, super.key});

  @override
  State<BudgetSettingPage> createState() => _BudgetSettingPageState();
}

class _BudgetSettingPageState extends State<BudgetSettingPage> with TickerProviderStateMixin{
  Logger logger = Logger();
  bool isloading = true;
  final TextEditingController _textFieldController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldBudgetMonthKey = GlobalKey<ScaffoldState>();
  final TextEditingController _categoryFieldController = TextEditingController();
  List<BudgetSetting> budgetSet = [];
  List<Map<String, dynamic>>expenseData= [];
  double totalExpenseAmount= 0;
  bool isPercentageChannels = true;
  List<String> categoryData = [];
  List<String> budgetCategoryData = [];

  late AnimationController _animationController;
  late Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    _fetchDatas();
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(end: 1.0, begin: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          
        });
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  Future<void> _fetchDatas() async {
    isloading = true;
    List<String> localCategoryData = [];
    List<String> localBudgetCategoryData = [];
    double localTotalExpenseAmount= 0;
    List<BudgetSetting> fetchedBudgetSet = await DatabaseAdmin().getMonthBugetList(widget.year, widget.month);
    List<Map<String, dynamic>> fetchedExpenseData =  await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.year,widget.month);
    List<Map<String, dynamic>> localexpenseData = [...fetchedExpenseData];
    if (fetchedBudgetSet.isNotEmpty && fetchedBudgetSet[0].budgetList != null) {
      for (var key in fetchedBudgetSet[0].budgetList!.keys) {
        localCategoryData.add(key);
        localBudgetCategoryData.add(key);
      }
    }
    localexpenseData.sort((previous, next) => next['totalAmount'].compareTo(previous['totalAmount']));
    for (var data in localexpenseData) {
      localCategoryData.add(data['category']);
      localTotalExpenseAmount = localTotalExpenseAmount + data['totalAmount'];
    }
    localCategoryData = localCategoryData.toSet().toList();
    localCategoryData.remove('총 예산');
    localBudgetCategoryData.remove('총 예산');
    if (mounted) {
      setState(() {
        expenseData = fetchedExpenseData;
        budgetSet = fetchedBudgetSet;
        categoryData = localCategoryData;
        budgetCategoryData = localBudgetCategoryData;
        totalExpenseAmount = localTotalExpenseAmount;
        isloading = false;
      });
      // logger.d(budgetCategoryData) ;   
      // logger.d(budgetSet[0].budgetList) ;   
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return Scaffold(
        key: _scaffoldBudgetMonthKey,
        body: const Center(child: CircularProgressIndicator())
      );
    } else if (budgetSet.isEmpty && !isloading) {
      return Scaffold(
        key: _scaffoldBudgetMonthKey,
        appBar: AppBar(title: Text('${widget.year}년 ${widget.month}월'),),
        body: emptyBudgetWidget()
      );
    } else {
      return Scaffold(
        key: _scaffoldBudgetMonthKey,
        appBar: AppBar(title: Text('${widget.year}년 ${widget.month}월'),),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  const Text('예산 총액', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final value = budgetSet[0].budgetList!['총 예산'];
                          _textFieldController.text = value.toString();
                          return AlertDialog(
                            title: Text('${widget.year}년 ${widget.month}월 예산 수정'),
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
                                    updateNewBudgetToDatabase('총 예산', double.parse(_textFieldController.text), budgetSet[0].budgetList!);
                                    _textFieldController.clear();
                                    _fetchDatas();
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('수정'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(CupertinoIcons.pencil)
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPercentageChannels = !isPercentageChannels;
                  });
                },
                child: PercentageGaugeBar(childNumber: totalExpenseAmount,motherNumber: budgetSet[0].budgetList!['총 예산']!, isPercentage: isPercentageChannels)
              ),
              const Divider(height: 50),
              Align(
                alignment: const Alignment(0.8,0.5),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if(_animationStatus == AnimationStatus.dismissed) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  icon: const Icon(Icons.autorenew),
                )
              ),
              Expanded(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(2,1,0.0015)
                    ..rotateY(pi*(_animation.value % 1.0)),
                    child: _animation.value<=0.5
                    ? percetageChanel(budgetSet, expenseData, categoryData)
                    : budgetChanel(budgetSet, budgetCategoryData)
                ),
              )
            ],
          ),
        ),
      );
    }
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
                          _fetchDatas();
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
    return GestureDetector(
      onTap: () {
        setState(() {
          isPercentageChannels = !isPercentageChannels;
        });
      },
      child: Column(
        key: const Key('percentage'),
        children: [
          Expanded(
            child: ListView.builder(
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(key, style: const TextStyle(fontSize: 24)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: PercentageGaugeBar(childNumber: valueB,motherNumber: valueA, isThick: false, isPercentage: isPercentageChannels)
                      )
                    ]
                  ),
                );
              },
            )
          )   
        ],
      ),
    );
  }


  /// 세부 예산 항목
  Widget budgetChanel(List<BudgetSetting> budgetSet, List<String> budgetCategoryData) {
    return Column(
      key: const Key('budget'),
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
                              _fetchDatas();
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
        Expanded(
          child: ListView.builder(
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(key, style: const TextStyle(fontSize: 24)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(value.toString(), textAlign: TextAlign.end ,style: const TextStyle(fontSize: 24)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: GestureDetector(
                        onTap:() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              _textFieldController.text = value.toString();
                              return AlertDialog(
                                title: const Text('항목 수정'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(key, textAlign: TextAlign.left,),
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
                                        if(budgetSet[0].budgetList != null) {
                                          updateNewBudgetToDatabase(key, double.parse(_textFieldController.text), budgetSet[0].budgetList!);
                                          _textFieldController.clear();
                                          _fetchDatas();
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('수정'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(CupertinoIcons.pencil)
                      )
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('항목 삭제'),
                                content: const Text('선택한 항목을 삭제하시겠습니까?'),
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
                                        if(budgetSet[0].budgetList != null) {
                                          deleteBudgetFormListDatabase(key, budgetSet[0].budgetList!);
                                          _fetchDatas();
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('삭제'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ),
                  ],
                )
              );
            },
          )
        )
      ],
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

  void deleteBudgetFormListDatabase(String category, Map<String, double> budgetlist) {
    final Map<String, double>  updatedBudgetList = Map.from(budgetlist);

    updatedBudgetList.remove(category);

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
              return AutoSizeText(maxLines: 3,'Error: ${snapshot.error}');
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
                        return category.itemList!.where((item) => item != '특별 예산').map((item) { 
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



///연간 예산 설정 페이지
class BudgetSettingYearlyPage extends StatefulWidget {
  final int year;
  const BudgetSettingYearlyPage({required this.year, super.key});

  @override
  State<BudgetSettingYearlyPage> createState() => _BudgetSettingYearlyPageState();
}

class _BudgetSettingYearlyPageState extends State<BudgetSettingYearlyPage> with TickerProviderStateMixin{
  Logger logger = Logger();
  bool isloading = true;
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _textFieldInputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldBudgetMonthKey = GlobalKey<ScaffoldState>();
  final TextEditingController _categoryFieldController = TextEditingController(text: '특별 예산');
  final int month = 13;
  List<BudgetSetting> budgetSet = [];
  List<Map<String, dynamic>>expenseData= [];
  double totalExpenseAmount= 0;
  bool isPercentageChannels = true;
  List<String> categoryData = [];
  List<String> budgetCategoryData = [];

  late AnimationController _animationController;
  late Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    _fetchDatas();
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween(end: 1.0, begin: 0.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          
        });
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
    _textFieldController.addListener(_formatInput);
  }

  @override
  void dispose() {
    _textFieldController.removeListener(_formatInput);
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _fetchDatas() async {
    isloading = true;
    List<String> localCategoryData = [];
    List<String> localBudgetCategoryData = [];
    double localTotalExpenseAmount= 0;
    List<BudgetSetting> fetchedBudgetSet = await DatabaseAdmin().getMonthBugetList(widget.year, month);
    List<Map<String, dynamic>> fetchedExpenseData =  await DatabaseAdmin().getYearlySumByCategory(widget.year);
    List<Map<String, dynamic>> localexpenseData = [...fetchedExpenseData];
    if (fetchedBudgetSet.isNotEmpty && fetchedBudgetSet[0].budgetList != null) {
      for (var key in fetchedBudgetSet[0].budgetList!.keys) {
        localCategoryData.add(key);
        localBudgetCategoryData.add(key);
      }
    }
    localexpenseData.sort((previous, next) => next['totalAmount'].compareTo(previous['totalAmount']));
    for (var data in localexpenseData) {
      // localCategoryData.add(data['category']);
      localTotalExpenseAmount = localTotalExpenseAmount + data['totalAmount'];
    }
    localCategoryData = localCategoryData.toSet().toList();
    localCategoryData.remove('총 예산');
    localBudgetCategoryData.remove('총 예산');
    if (mounted) {
      setState(() {
        expenseData = fetchedExpenseData;
        budgetSet = fetchedBudgetSet;
        categoryData = localCategoryData;
        budgetCategoryData = localBudgetCategoryData;
        totalExpenseAmount = localTotalExpenseAmount;
        isloading = false;
      });
      // logger.d(budgetCategoryData) ;   
      // logger.d(budgetSet[0].budgetList) ;   
    }
  }

  void _formatInput() {
    String newText = _textFieldController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) return;

    final int value = int.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(value);

    // 포맷된 텍스트를 다시 설정 (커서 위치를 조정하여 깜빡임 방지)
    _textFieldController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
    _textFieldInputController.text = _textFieldController.text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return Scaffold(
        key: _scaffoldBudgetMonthKey,
        body: const Center(child: CircularProgressIndicator())
      );
    } else if (budgetSet.isEmpty && !isloading) {
      return Scaffold(
        key: _scaffoldBudgetMonthKey,
        appBar: AppBar(title: Text('${widget.year}년'),),
        body: emptyBudgetWidget()
      );
    } else {
      return Scaffold(
        key: _scaffoldBudgetMonthKey,
        appBar: AppBar(title: Text('${widget.year}년'),),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 10),
                  const Text('예산 총액', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final value = budgetSet[0].budgetList!['총 예산'];
                          _textFieldController.text = value.toString();
                          return AlertDialog(
                            title: Text('${widget.year}년 예산 수정'),
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
                                  keyboardType: TextInputType.number,
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
                                    updateNewBudgetToDatabase('총 예산', double.parse(_textFieldInputController.text), budgetSet[0].budgetList!);
                                    _textFieldController.clear();
                                    _fetchDatas();
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('수정'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(CupertinoIcons.pencil)
                  ),
                ],
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPercentageChannels = !isPercentageChannels;
                  });
                },
                child:PercentageGaugeBar(childNumber: totalExpenseAmount,motherNumber: budgetSet[0].budgetList!['총 예산']!, isPercentage: isPercentageChannels)
              ),
              const Divider(height: 50),
              Align(
                alignment: const Alignment(0.8,0.5),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if(_animationStatus == AnimationStatus.dismissed) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  icon: const Icon(Icons.autorenew),
                )
              ),
              Expanded(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(2,1,0.0015)
                    ..rotateY(pi*(_animation.value % 1.0)),
                    child: _animation.value<=0.5
                    ? percetageChanel(budgetSet, expenseData, categoryData)
                    : budgetChanel(budgetSet, budgetCategoryData)
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  /// 키보드 위 간단 숫자 입력 버튼
  Widget _changeAmountOutlinedButton(String text, Function() onPressed) {
    return Container(
      margin: EdgeInsets.all(MediaQuery.of(context).size.width*0.005), // 버튼의 마진
      child: OutlinedButton(
        onPressed: () => onPressed(),
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(
            EdgeInsets.all(MediaQuery.of(context).size.width*0.0005), // adaptive padding
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              return Colors.transparent;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              return BorderSide(color: Colors.green.withOpacity(0.9));
            },
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
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
                  title: Text('${widget.year}년 예산 등록'),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _changeAmountOutlinedButton("100K", () {
                            String amountText  = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                            _textFieldInputController.text = amountText =='' ? '0' : amountText;
                            _textFieldInputController.text = ((double.parse(_textFieldInputController.text) % 1 == 0) ? (double.parse(_textFieldInputController.text) + 100000).toStringAsFixed(0) : (double.parse(_textFieldInputController.text) + 1000).toString());
                            _textFieldController.text = _textFieldInputController.text;
                          }),
                          _changeAmountOutlinedButton("500K", () {
                            String amountText  = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                            _textFieldInputController.text = amountText =='' ? '0' : amountText;
                            _textFieldInputController.text = ((double.parse(_textFieldInputController.text) % 1 == 0) ? (double.parse(_textFieldInputController.text) + 500000).toStringAsFixed(0) : (double.parse(_textFieldInputController.text) + 5000).toString());
                            _textFieldController.text = _textFieldInputController.text;
                          }),
                          _changeAmountOutlinedButton("1M", () {
                            String amountText  = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                            _textFieldInputController.text = amountText =='' ? '0' : amountText;
                            _textFieldInputController.text = ((double.parse(_textFieldInputController.text) % 1 == 0) ? (double.parse(_textFieldInputController.text) + 1000000).toStringAsFixed(0) : (double.parse(_textFieldInputController.text) + 10000).toString());
                            _textFieldController.text = _textFieldInputController.text;
                          }),
                          _changeAmountOutlinedButton("10M", () {
                            String amountText  = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                            _textFieldInputController.text = amountText =='' ? '0' : amountText;
                            _textFieldInputController.text = ((double.parse(_textFieldInputController.text) % 1 == 0) ? (double.parse(_textFieldInputController.text) + 10000000).toStringAsFixed(0) : (double.parse(_textFieldInputController.text) + 100000).toString());
                            _textFieldController.text = _textFieldInputController.text;
                          }),
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
                          insertNewBudgetToDatabase();
                          _textFieldController.clear();
                          _fetchDatas();
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
    return GestureDetector(
      onTap: () {
        setState(() {
          isPercentageChannels = !isPercentageChannels;
        });
      },
      child: Column(
        key: const Key('percentage'),
        children: [
          Expanded(
            child: ListView.builder(
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(key, style: const TextStyle(fontSize: 24)),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: PercentageGaugeBar(childNumber: valueB,motherNumber: valueA, isThick: false, isPercentage: isPercentageChannels)
                      )
                    ]
                  ),
                );
              },
            )
          )   
        ],
      ),
    );
  }


  /// 세부 예산 항목
  Widget budgetChanel(List<BudgetSetting> budgetSet, List<String> budgetCategoryData) {
    return Column(
      key: const Key('budget'),
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('${widget.year}년 특별 예산 등록'),
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
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (double.parse(_textFieldInputController.text) > budgetSet[0].budgetList!['총 예산']!) {
                            // 조건을 만족하면 토스트 메시지 표시 후 함수 종료
                            Fluttertoast.showToast(
                              msg: "특별 예산이 총 예산을 넘었습니다.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return;
                          }
                          setState(() {
                            if(budgetSet[0].budgetList != null) {
                              updateNewBudgetToDatabase(_categoryFieldController.text, double.parse(_textFieldInputController.text), budgetSet[0].budgetList!);
                              _textFieldController.clear();
                              _fetchDatas();
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
        Expanded(
          child: ListView.builder(
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(key, style: const TextStyle(fontSize: 24)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: Text(value.toString(), textAlign: TextAlign.end ,style: const TextStyle(fontSize: 24)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: GestureDetector(
                        onTap:() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              _textFieldController.text = value.toString();
                              return AlertDialog(
                                title: const Text('항목 수정'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(key, textAlign: TextAlign.left,),
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
                                        if(budgetSet[0].budgetList != null) {
                                          updateNewBudgetToDatabase(key, double.parse(_textFieldInputController.text), budgetSet[0].budgetList!);
                                          _textFieldController.clear();
                                          _fetchDatas();
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('수정'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Icon(CupertinoIcons.pencil)
                      )
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('항목 삭제'),
                                content: const Text('선택한 항목을 삭제하시겠습니까?'),
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
                                        if(budgetSet[0].budgetList != null) {
                                          deleteBudgetFormListDatabase(key, budgetSet[0].budgetList!);
                                          _fetchDatas();
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text('삭제'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    ),
                  ],
                )
              );
            },
          )
        )
      ],
    );
  }

  void insertNewBudgetToDatabase() {
    final BudgetSetting newBudget = BudgetSetting(
      year : widget.year,
      month : month, 
      budgetList: <String,double>{"총 예산": double.parse(_textFieldInputController.text)},
    );

    DatabaseAdmin().insertBugetSettingTable(newBudget);
  }

  void updateNewBudgetToDatabase(String category, double value, Map<String, double> budgetlist) {
    final Map<String, double>  updatedBudgetList = Map.from(budgetlist);

    updatedBudgetList[category] = value;

    DatabaseAdmin().updateBugetSettingTable(widget.year, month, updatedBudgetList);
  }

  void deleteBudgetFormListDatabase(String category, Map<String, double> budgetlist) {
    final Map<String, double>  updatedBudgetList = Map.from(budgetlist);

    updatedBudgetList.remove(category);

    DatabaseAdmin().updateBugetSettingTable(widget.year, month, updatedBudgetList);
  }
}



class ExtraTransactionGrid {
  ExtraTransactionGrid({required this.dataid, required this.name, required this.category, required this.amount});
  final String dataid;
  final String name;
  String category;
  final int amount;
}

class ExtraTransactionSource extends DataGridSource {
  final List<ExtraTransactionGrid> extraTransaction;
  final Function(String, String)? afterEdit;
  ExtraTransactionSource({required this. extraTransaction, this.afterEdit}) {
    dataGridRows = extraTransaction
      .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
        DataGridCell<String>(columnName: 'id', value: dataGridRow.dataid),
        DataGridCell<String>(columnName: 'name', value: dataGridRow.name),
        DataGridCell<String>(
            columnName: 'category', value: dataGridRow.category),
        DataGridCell<int>(
            columnName: 'amount', value: dataGridRow.amount),
      ]))
      .toList();
  }
  @override
  List<DataGridRow> get rows => dataGridRows;
  
  List<DataGridRow> dataGridRows = [];


  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: (dataGridCell.columnName == 'amount')
              ? Alignment.centerRight
              : Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            (dataGridCell.columnName == 'amount')
              ?  NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR", ).format(dataGridCell.value.abs()).toString()
              : dataGridCell.value.toString(),
            style: (dataGridCell.columnName == 'id') ? const TextStyle(fontSize: 8) : const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }

  /// Helps to hold the new value of all editable widgets.
  /// Based on the new value we will commit the new value into the corresponding
  /// DataGridCell on the onCellSubmit method.
  dynamic newCellValue;

  TextEditingController editingController = TextEditingController();
  
  @override
  bool onCellBeginEdit(
      DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) {
    if (column.columnName != 'category') {
      // Return false, to restrict entering into the editing.
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<bool> canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) async{
    if (column.columnName == 'id' && newCellValue == null) {
      // Return false, to retain in edit mode.
      // To avoid null value for cell
      return false;
    } else {
      return true;
    }
  }

  @override
  void onCellCancelEdit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column) {
    // handle the cancel editing code here
  }

  @override
  Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
      GridColumn column)  async {
    final dynamic oldValue = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value ??
        '';

    final int dataRowIndex = dataGridRows.indexOf(dataGridRow);

    if (newCellValue == null || oldValue == newCellValue) {
      return;
    }

    if (column.columnName == 'category') {
      dataGridRows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
          DataGridCell<String>(columnName: 'category', value: newCellValue);
      extraTransaction[dataRowIndex].category = newCellValue.toString();
      afterEdit?.call(newCellValue.toString(), extraTransaction[dataRowIndex].dataid);
    }
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    // Text going to display on editable widget
    final String displayText = dataGridRow
            .getCells()
            .firstWhereOrNull((DataGridCell dataGridCell) =>
                dataGridCell.columnName == column.columnName)
            ?.value
            ?.toString() ??
        '';

    // The new cell value must be reset.
    // To avoid committing the [DataGridCell] value that was previously edited
    // into the current non-modified [DataGridCell].
    newCellValue = null;
    editingController. text = displayText;
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        controller: editingController,
        textAlign: TextAlign.left,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
        ),
        onChanged: (String value) {
          if (value.isNotEmpty) {
            newCellValue = value;
          } else {
            newCellValue = null;
          }
        },
        onSubmitted: (String value) {

          submitCell();
        },
      ),
    );
  }
}



///특별 예산 상세 페이지
class ExtraBudgetGroupDetail extends StatefulWidget {
  final int id;
  const ExtraBudgetGroupDetail({required this.id, super.key});

  @override
  State<ExtraBudgetGroupDetail> createState() => _ExtraBudgetGroupDetailState();
}

class _ExtraBudgetGroupDetailState extends State<ExtraBudgetGroupDetail> {
  final DataGridController _dataGridController = DataGridController();
  final List<ExtraTransactionGrid> _tableData = <ExtraTransactionGrid>[];
  String title = "";
  Color titleColor = Colors.white;
  List<int> selectedTransactionData = [];
  List<Map<String, dynamic>> _tableRawData = [];
  late ExtraTransactionSource _tableDataSource;
  List<Map<String,double>> _chartMap = [];


  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  @override
  void dispose() {
    _dataGridController.dispose();
    super.dispose();
  }

  Future<void> fetchDatas() async{
    await fetchBaseDatas();
    fetchTabelDataGrid();
    fetchChartMap();
  }

  Future<void> fetchBaseDatas() async{
    ExtraBudgetGroup? fetchGroupData;
    fetchGroupData = await DatabaseAdmin().getExtraGroupDatasById(widget.id);
    setState(() {
      if(fetchGroupData != null) {
        title = fetchGroupData.dataList!['title'];
        titleColor = Color(fetchGroupData.dataList!['backGroundColor']);
        if (fetchGroupData.dataList!.containsKey('tableData')) {
          _tableRawData = List<Map<String, dynamic>>.from(fetchGroupData.dataList!['tableData']);
          fetchTableData();
        }
        // if (fetchGroupData.dataList!.containsKey('subTableData')) {
        //   for (var datarow in fetchGroupData.dataList!['subTableData']) {
        //     _tableData.add(ExtraTransactionGrid(datarow['id'],datarow['name'],datarow['category'],datarow['amount']));
        //   }
        // }
      } else {
        Navigator.pop(context);
      }
    });
  }

  void fetchTableData() {
    setState(() {
      for(var rows in _tableRawData) {
        _tableData.removeWhere((row) => !_tableRawData.any((rawRow) => rawRow['dataid'] == row.dataid));
        if (_tableData.isEmpty || !(_tableData.any((tableRow) => tableRow.dataid == rows['dataid']))) {
          selectedTransactionData.add(rows['id']);
          _tableData.add(ExtraTransactionGrid(
            dataid: rows['dataid'],
            name: rows['goods'],
            category: rows['category'],
            amount: rows['amount'],
          ));
        }
      }
    });
  }  


  void fetchTabelDataGrid() {
    setState(() {
      _tableDataSource = ExtraTransactionSource(
        extraTransaction: _tableData,
        afterEdit: (String newValue, String dataID) {
          setState(() {
            var rowToUpdate = _tableRawData.firstWhereOrNull((row) => row['dataid'] == dataID);
            if (rowToUpdate != null) {
              rowToUpdate['category'] = newValue;
              updateDataToDatabase(_tableRawData);
            }
            fetchChartMap();
          });
        }
      );
    });
  }

  void fetchChartMap(){
    List<Map<String,double>> localMap = [];
    Map<String, double> categoryTotal = {};

    for (var transaction in _tableData) {
      if (categoryTotal.containsKey(transaction.category)) {
        categoryTotal[transaction.category] = categoryTotal[transaction.category]! + transaction.amount.toDouble();
      } else {
        categoryTotal[transaction.category] = transaction.amount.toDouble();
      }
    }


    categoryTotal.forEach((key, value) {
    Map<String, double> map = {key: value};
      localMap.add(map);
    });
    setState(() {
     _chartMap = localMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$title 상세',
          style: TextStyle(
            color: (titleColor.red +titleColor.green + titleColor.blue) /3 > 127
              ?Colors.black : Colors.white
          ),
        ),
        backgroundColor: titleColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: (titleColor.red +titleColor.green + titleColor.blue) /3 > 127
              ?Colors.black : Colors.white,
            onPressed: () {
              _showDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: selectedTransactionData.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
            children:[
              if(selectedTransactionData.isEmpty)
              Center(
                child: SizedBox(
                  height: 100,
                  child: OutlinedButton(
                    onPressed: (){
                      _showDialog();
                    }, 
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(width: 4, color: Colors.cyan.shade700)
                    ),
                    child: Text('소비 내역 추가하기', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.cyan.shade700),)
                  )
                )
              )
              else
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SfDataGridTheme(
                      data: SfDataGridThemeData(headerColor: Theme.of(context).colorScheme.inversePrimary),
                      child:SfDataGrid(
                        source: _tableDataSource,
                        controller: _dataGridController,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerGridLinesVisibility : GridLinesVisibility.none,
                        gridLinesVisibility: GridLinesVisibility.vertical,
                        allowEditing: true,
                        navigationMode: GridNavigationMode.cell,
                        onCellTap:  (DataGridCellTapDetails details) {
                          _dataGridController.beginEdit(
                            RowColumnIndex(details.rowColumnIndex.rowIndex-1,details.rowColumnIndex.columnIndex)
                          );
                        },
                        selectionMode: SelectionMode.single,
                        columns: [
                          GridColumn(
                            columnName: 'id',
                            allowEditing: false,
                            label: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              )
                            )
                          ),
                          GridColumn(
                            columnName: 'name',
                            minimumWidth: 130,
                            allowEditing: false,
                            label: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              )
                            )
                          ),
                          GridColumn(
                            columnName: 'category',
                            minimumWidth: 100,
                            label: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Category',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              )
                            )
                          ),
                          GridColumn(
                            columnName: 'amount',
                            minimumWidth: 140,
                            allowEditing: false,
                            label: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              alignment: Alignment.center,
                              child: const Text(
                                'Amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              )
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(_chartMap != [])
                  Column(
                    children: [PieChartByExtraBudget(key: UniqueKey(),dataMap: _chartMap,)]
                  ), 
                ],
              )
            ]
          )
        ),
      )
    );
  }

  /// 특별 예산 내역 선택
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child:FutureBuilder<List<MoneyTransaction>>(
                future: DatabaseAdmin().getExtrabugetcategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<MoneyTransaction> extraTransactionDatas = snapshot.data ?? [];
                    List<MoneyTransaction> localselectedTransactionData = [];
                    for (var id in selectedTransactionData) {
                      localselectedTransactionData.add(
                        extraTransactionDatas.firstWhere((transaction) => transaction.id == id)
                      );
                    }
                    logger.d(localselectedTransactionData.length);
                    logger.d(selectedTransactionData.length);
                    if (extraTransactionDatas.isEmpty) {
                      return const Center(child: Text('No data available', style: TextStyle(fontSize: 32),));
                    }
                    return  Column(
                          mainAxisSize:  MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: extraTransactionDatas.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(
                                      selectedTransactionData.contains(extraTransactionDatas[index].id)
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color: selectedTransactionData.contains(extraTransactionDatas[index].id)
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    title: Text(extraTransactionDatas[index].goods),
                                    subtitle: Text(extraTransactionDatas[index].id!.toString()),
                                    onTap: () {
                                      setState(() {
                                        if (selectedTransactionData.contains(extraTransactionDatas[index].id)) {
                                          selectedTransactionData.remove(extraTransactionDatas[index].id);
                                          localselectedTransactionData.remove(extraTransactionDatas[index]);
                                        } else {
                                          selectedTransactionData.add(extraTransactionDatas[index].id!);
                                          localselectedTransactionData.add(extraTransactionDatas[index]);
                                        }
                                        // logger.d(selectedTransactionData);
                                      });
                                    },
                                  );
                                },
                              )
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(localselectedTransactionData);
                              },
                              child: const Text('확인', style: TextStyle(fontSize: 24),),
                            ),
                          ]
                        );
                      }
                    }
                  )
                )
              );
            }
          )
        );
      }
    ).then((selectedData) {
      setState(() {
        try {
          if (_tableRawData.isEmpty) {
            _tableRawData.addAll(
              selectedData
                .map<Map<String, dynamic>>((transaction) => {
                  'id': transaction.id,
                  'dataid': '${"${transaction.id}000${widget.id}".hashCode}',
                  'date': transaction.transactionTime,
                  'goods': transaction.goods,
                  'category': transaction.category,
                  'amount': transaction.amount.toInt(),
                })
            );
          } else {
            _tableRawData.addAll(
              selectedData
                .map<Map<String, dynamic>>((transaction) => {
                  'id': transaction.id,
                  'dataid': '${"${transaction.id}000${widget.id}".hashCode}',
                  'date': transaction.transactionTime,
                  'goods': transaction.goods,
                  'category': transaction.category,
                  'amount': transaction.amount.toInt(),
                })
                .where((transaction) =>
                    !_tableRawData.any((row) => row['id'] == transaction['id'])),
            );
          }
          _tableRawData.removeWhere((row) => !selectedData.any((transaction) => transaction.id == row['id']));
          updateDataToDatabase(_tableRawData);
          fetchTableData();
          fetchTabelDataGrid();
          fetchChartMap();
        } catch (e) {
          logger.e(e);
        }
      });
    });
  }

  void updateDataToDatabase(List<Map<String, dynamic>> jsonfyTableData) {
    final ExtraBudgetGroup updatedGroup = ExtraBudgetGroup(
      id: widget.id, 
      dataList: {
        'title':title,
        'backGroundColor': titleColor.value,
        'selectedTransactionData': selectedTransactionData,
        'tableData': jsonfyTableData,
      }
    );
    // 데이터베이스에 은행 계좌 정보 장장
    DatabaseAdmin().updateExtraGroup(updatedGroup);
  }
}
