import 'dart:math';
import 'dart:async';
// import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/synchro_bar_charts.dart';
import 'package:ver_0_2/widgets/synchro_pie_charts.dart';
import 'package:ver_0_2/widgets/synchro_line_charts.dart';
import 'package:ver_0_2/widgets/synchro_data_grid.dart';
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
          if(widget.monthBack != null)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: widget.monthBack,
          ),
          // GestureDetector(
          //   child: 
          // ),
          Text(widget.monthBack != null ? '${widget.year} 년 ${widget.month} 월' : '${widget.year} 년'),
          if(widget.monthForward != null)
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
  final bool isNotCompareBar;
  final Function(bool) onCompareBarToggle;
  const MonthlyConsumePage({
    required this.year,
    required this.month,
    required this.isNotCompareBar,
    required this.onCompareBarToggle,
    super.key
  });

  @override
  State<MonthlyConsumePage> createState() => _MonthlyConsumePageState();
}

class _MonthlyConsumePageState extends State<MonthlyConsumePage>{
  final PageController _pageController = PageController();
  int pastyear = DateTime.now().year;
  int pastmonth = DateTime.now().month;
  double totalExpense = 0;
  double totalExpenseNegative = 0;
  // bool isNotCompareBar = false;
  String selectCategory = "";

  @override
  void initState() {
    super.initState();
    setPastDate();
    _fetchExpenseDatas();
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

  Future<void> _fetchExpenseDatas() async {
    double totalValue = 0;
    double totalNValue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.year,widget.month)).toList();
    fetchedDatas.sort((prev, next) => next['totalAmount'].compareTo(prev['totalAmount']));
    for (var data in fetchedDatas) {
      totalValue = totalValue + data['totalAmount'];
    }

    List<Map<String, dynamic>> fetchedNegativeDatas = (await DatabaseAdmin().getTransactionsSUMByCategoryMonthNegative(widget.year,widget.month)).toList();
    fetchedNegativeDatas.sort((prev, next) => next['totalAmount'].compareTo(prev['totalAmount']));
    for (var data in fetchedNegativeDatas) {
      totalNValue = totalNValue + data['totalAmount'];
    }

    if (mounted) {
      setState(() {
        totalExpense = totalValue;
        totalExpenseNegative = totalNValue;
      });
    }
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
                        if(!widget.isNotCompareBar)
                        const Text('전월 비교',style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        if(widget.isNotCompareBar)
                        const Text('비용 비율',style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 5,),
                        Switch.adaptive(
                          value: widget.isNotCompareBar,
                          activeColor: Colors.teal,
                          activeTrackColor: Colors.teal.shade200,
                          inactiveThumbColor: Colors.teal,
                          inactiveTrackColor: Colors.teal.shade200,
                          onChanged: (bool value) {
                            widget.onCompareBarToggle(value);
                            setState(() {
                              // widget.isNotCompareBar = value;
                              setPastDate();
                              selectCategory = "";
                            });
                          },
                        ),
                        const SizedBox(width: 20,),
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
            if(!widget.isNotCompareBar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${widget.year}-${widget.month.toString().padLeft(2, '0')}',style: const TextStyle(fontSize: 20),),
                const Text('  vs  ',style: TextStyle(fontSize: 20),),
                Text('$pastyear-${pastmonth.toString().padLeft(2, '0')}',style: const TextStyle(fontSize: 20),),
              ],
            ),
            if(widget.isNotCompareBar)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: totalExpense),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Text(
                      'In total ${NumberFormat.simpleCurrency(
                        decimalDigits: totalExpense % 1 == 0 ? 0 : 2,
                        locale: "ko-KR",
                      ).format(value)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const SizedBox(width: 8), // 두 텍스트 간 여백
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: totalExpenseNegative),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Text(
                      'Expense ${NumberFormat.simpleCurrency(
                        decimalDigits: totalExpenseNegative % 1 == 0 ? 0 : 2,
                        locale: "ko-KR",
                      ).format(value)}',
                      style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.red),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
            if(!widget.isNotCompareBar)
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
            if(widget.isNotCompareBar)
            Expanded(
              child: PieChartsByCategoryMonth(
                key: UniqueKey(),
                year: widget.year,
                month: widget.month,
                onPieSelected: (ChartPointDetails pointInteractionDetails) {
                  if(pointInteractionDetails.dataPoints != null) {
                    var detailList = pointInteractionDetails.dataPoints;
                    if (pointInteractionDetails.pointIndex != null && detailList![pointInteractionDetails.pointIndex!].x != 'etc') {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() {
                        selectCategory = detailList[pointInteractionDetails.pointIndex!].x;
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
  final TextEditingController _textFieldInputController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldBudgetMonthKey = GlobalKey<ScaffoldState>();
  final TextEditingController _categoryFieldController = TextEditingController();
  List<BudgetSetting> budgetSet = [];
  List<Map<String, dynamic>>expenseData= [];
  double totalExpenseAmount= 0;
  double totalSubBudgetAmount= 0;
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
    double localTotalSubBudgetAmount= 0;
    List<BudgetSetting> fetchedBudgetSet = await DatabaseAdmin().getMonthBugetList(widget.year, widget.month);
    List<Map<String, dynamic>> fetchedExpenseData =  await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.year,widget.month);
    List<Map<String, dynamic>> localexpenseData = [...fetchedExpenseData];
    if (fetchedBudgetSet.isNotEmpty && fetchedBudgetSet[0].budgetList != null) {
      // logger.i(fetchedBudgetSet[0].budgetList!);
      for (var key in fetchedBudgetSet[0].budgetList!.keys) {
        localCategoryData.add(key);
        localBudgetCategoryData.add(key);
        if (key != '총 예산') {
          localTotalSubBudgetAmount = localTotalSubBudgetAmount + fetchedBudgetSet[0].budgetList![key]!.toDouble();
        }
      }
      // for (var valueAmount in fetchedBudgetSet[0].budgetList!.values) {
      // }
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
        totalSubBudgetAmount = localTotalSubBudgetAmount;
        isloading = false;
      });
      // logger.d(budgetSet);   
      // logger.d(budgetSet[0].budgetList) ;   
    }
  }

  void _formatInput() {
    String newText = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (newText.isEmpty) return;

    int firstDotIndex = newText.indexOf('.');
    if (firstDotIndex != -1) {
      newText = '${newText.substring(0, firstDotIndex + 1)}${newText.substring(firstDotIndex + 1).replaceAll('.', '')}';
    }

    final double value = double.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: value%1==0? 0: 2, locale: "ko-KR").format(value);

    // 포맷된 텍스트를 다시 설정 (커서 위치를 조정하여 깜빡임 방지)
    final cursorPosition = _textFieldController.selection.base.offset;
    _textFieldController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: formattedText.length < cursorPosition? formattedText.length : cursorPosition,
      ),
    );
    _textFieldInputController.text = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
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
                child: PercentageGaugeBar(childNumber: totalExpenseAmount,motherNumber: budgetSet[0].budgetList!['총 예산']!, isPercentage: isPercentageChannels)
              ),
              const Divider(height: 50),
              Row(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('세부 예산 여분:     ${NumberFormat.simpleCurrency(decimalDigits: 2, locale: "ko-KR").format(budgetSet[0].budgetList!['총 예산']! - totalSubBudgetAmount)}',
                   style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic, color: budgetSet[0].budgetList!['총 예산']! - totalSubBudgetAmount > 0 ?  Colors.lightGreen : Colors.deepOrange),
                  ),
                  IconButton(
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
                ],
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
                              updateNewBudgetToDatabase(_categoryFieldController.text, double.parse(_textFieldInputController.text), budgetSet[0].budgetList!);
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
      month : widget.month, 
      budgetList: <String,double>{"총 예산": double.parse(_textFieldInputController.text)},
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
                onPieDoubleSelected: (ChartPointDetails pointInteractionDetails) {
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
    String newText = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (newText.isEmpty) return;

    int firstDotIndex = newText.indexOf('.');
    if (firstDotIndex != -1) {
      newText = '${newText.substring(0, firstDotIndex + 1)}${newText.substring(firstDotIndex + 1).replaceAll('.', '')}';
    }


    final double value = double.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: value%1==0? 0: 2, locale: "ko-KR").format(value);

    final oldTextLength = _textFieldController.text.length;
    final cursorPosition = _textFieldController.selection.base.offset;
    
    final int offsetAdjustment = oldTextLength - cursorPosition;
    final int newCursorPosition = formattedText.length - offsetAdjustment;
    
    _textFieldController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: formattedText.length < newCursorPosition ? formattedText.length : newCursorPosition,
      ),
    );
    // _textFieldController.text = formattedText;
    _textFieldInputController.text = _textFieldController.text.replaceAll(RegExp(r'[^0-9.]'), '');
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
                    title: Text('${widget.year}년 연간 예산 항목 등록'),
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

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<TransactionCategory>(
          future: DatabaseAdmin().getYearlyExpenseCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 데이터 로딩 중이면 로딩 인디케이터 표시
            }
            if (snapshot.hasError) {
              return AutoSizeText(maxLines: 3,'Error: ${snapshot.error}');
            }
            List<String> fetchedCategorys = snapshot.data!.itemList ?? [];
            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3), // 원하는 최대 높이로 설정
              child:SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...fetchedCategorys.map((item) { 
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          setState(() {
                            _categoryFieldController.text = item;
                            Navigator.pop(context);
                          });
                        },
                      );
                    })
                  ],
                ),
              ),
            );
          },
        );
      },
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

///특별 예산 상세 페이지
class ExtraBudgetGroupDetail extends StatefulWidget {
  final int id;
  const ExtraBudgetGroupDetail({required this.id, super.key});

  @override
  State<ExtraBudgetGroupDetail> createState() => _ExtraBudgetGroupDetailState();
}

class _ExtraBudgetGroupDetailState extends State<ExtraBudgetGroupDetail> {
  Logger logger = Logger ();
  List<ExtraTransactionGrid> tableData = <ExtraTransactionGrid>[];
  String title = "";
  Color titleColor = Colors.white;
  List<int> selectedTransactionData = [];
  List<Map<String, dynamic>> _tableRawData = [];
  List<Map<String,double>> _chartMap = [];
  Future<List<MoneyTransaction>> budgetDataDB = Future.value([]);
  bool budgetDataLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDatas();
    fetchBudgetData();
  }

  Future<void> fetchDatas() async{
    await fetchBaseDatas();
    // fetchChartMap();
  }

  Future<void> fetchBaseDatas() async{
    ExtraBudgetGroup? fetchGroupData;
    fetchGroupData = await DatabaseAdmin().getExtraGroupDatasById(widget.id);
    // logger.e(fetchGroupData);
    setState(() {
      if(fetchGroupData != null) {
        title = fetchGroupData.dataList!['title'];
        titleColor = Color(fetchGroupData.dataList!['backGroundColor']);
        if (fetchGroupData.dataList!.containsKey('tableData')) {
          _tableRawData = List<Map<String, dynamic>>.from(fetchGroupData.dataList!['tableData']);
          // logger.d(_tableRawData);
          fetchTableData();
        }
      } else {
        Navigator.pop(context);
      }
    });
  }

  Future<void> fetchBudgetData() async {
    budgetDataDB = DatabaseAdmin().getExtrabugetcategory();
    setState(() {
      budgetDataLoading = false;
    });
  }

  void fetchTableData() {
    List<ExtraTransactionGrid> localtableData = [];
    for(var rows in _tableRawData) {
      selectedTransactionData.add(rows['id']);
      localtableData.add(ExtraTransactionGrid(
        dataid: rows['dataid'],
        name: rows['goods'],
        category: rows['category'],
        amount: rows['amount'],
      ));
    }
    setState(() {
      tableData = localtableData;
      selectedTransactionData = selectedTransactionData.toSet().toList();
      fetchChartMap();
    });
  } 
      // for(var rows in _tableRawData) {
      //   tableData.removeWhere((row) => !_tableRawData.any((rawRow) => rawRow['dataid'] == row.dataid));
      //   if (tableData.isEmpty || !(tableData.any((tableRow) => tableRow.dataid == rows['dataid']))) {
      //     selectedTransactionData.add(rows['id']);
      //     logger.d(1 );
      //     logger.d(rows['category']);
      //     tableData.add(ExtraTransactionGrid(
      //       dataid: rows['dataid'],
      //       name: rows['goods'],
      //       category: rows['category'],
      //       amount: rows['amount'],
      //     ));
      //   }
      // }

  void fetchChartMap(){
    List<Map<String,double>> localMap = [];
    Map<String, double> categoryTotal = {};
    for (var transaction in tableData) {
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
    // logger.i('localMap$localMap');
    setState(() {
     _chartMap = localMap;
    //  logger.i(_chartMap);
    });
  }

  void updatePage() {
    setState(() {
      fetchDatas();
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
          // IconButton(
          //   icon: const Icon(Icons.more_vert),
          //   color: (titleColor.red +titleColor.green + titleColor.blue) /3 > 127
          //     ?Colors.black : Colors.white,
          //   onPressed: () {
          //     _showDialog();
          //   },
          // ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: (titleColor.red + titleColor.green + titleColor.blue) / 3 > 127
                  ? Colors.black
                  : Colors.white,
            ),
            onSelected: (value) {
              // 메뉴 항목 선택 시 동작 정의
              // print("Selected: $value");
              switch (value) {
                case 'transacton_adminstration':
                  _showDialog();
                  break;
                case 'chart_selection':
                  // selectedWidget = const Book();
                  break;
                case 'option3':
                  // selectedWidget = const StatisticsView();
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return const [
                PopupMenuItem<String>(
                  value: 'transacton_adminstration',
                  child: Text('거래 내역 관리'),
                ),
                PopupMenuItem<String>(
                  value: 'chart_selection',
                  child: Text('차트 선택'),
                ),
                PopupMenuItem<String>(
                  value: 'option3',
                  child: Text('Option 3'),
                ),
              ];
            },
          )
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
                  ExtraBudgetDataGrid(id: widget.id,updatePageCallback: updatePage),
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

  // final ScrollController scrollDialogController = ScrollController();
  /// 특별 예산 내역 선택
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime firstDate = DateTime(2020, 1, 1);
        String searchKeyword = '';
        DateTime? startDate;
        DateTime? endDate;
        return Dialog(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: 
                  Column(
                    mainAxisSize:  MainAxisSize.min,
                    children: [ 
                      Row(
                        mainAxisSize:  MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: firstDate,
                                lastDate: DateTime.now(),
                              );
                              logger.i('picked: $picked');
                              if (picked != null) {
                                setState(() {
                                  startDate = picked.start;
                                  endDate = picked.end;
                                  logger.i(startDate);
                                  logger.i('endDate: $endDate');
                                });
                              }
                              // await fetchBudgetData();
                            },
                            child: Text(startDate != null && endDate != null
                                ? '${DateFormat("yy.MM.dd").format(startDate!)} ~ ${DateFormat("yy.MM.dd").format(endDate!)}'
                                : '기간 선택'),
                          ),
                          Expanded(
                            child: 
                            TextField(
                              decoration: const InputDecoration(
                                labelText: '항목 검색',
                                isDense: true,
                              ),
                              onChanged: (value)  {
                                logger.i('searchKeywordC: $searchKeyword');
                                setState(() {
                                  searchKeyword = value;
                                logger.i('searchKeywordCh: $searchKeyword');
                                  // fetchBudgetData();
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child:
                        FutureBuilder<List<MoneyTransaction>>(
                          future: budgetDataDB,
                          builder: (context, snapshot) {
                            // logger.d('loading');
                            if (snapshot.connectionState == ConnectionState.waiting || budgetDataLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              List<MoneyTransaction> extraTransactionDatas = snapshot.data ?? [];
                              List<MoneyTransaction> localselectedTransactionData = [];
                              for (var id in selectedTransactionData) {
                                try {
                                  final match = extraTransactionDatas.firstWhere((transaction) => transaction.id == id);
                                  localselectedTransactionData.add(match);
                                } catch (e) {
                                  logger.w('ID $id 에 해당하는 데이터를 찾을 수 없음: $e');
                                }
                              }
                              DateFormat format = DateFormat("yyyy년 MM월 dd일THH:mm");
                              extraTransactionDatas.sort((a, b) {
                                DateTime dateA = format.parse(a.transactionTime);
                                DateTime dateB = format.parse(b.transactionTime);
                                return dateA.compareTo(dateB);
                              });
                              firstDate = format.parse(extraTransactionDatas.first.transactionTime);
                              // logger.d(localselectedTransactionData.length);
                              // logger.d(selectedTransactionData.length);
                              if (extraTransactionDatas.isEmpty) {
                                return const Center(child: Text('No data available', style: TextStyle(fontSize: 32),));
                              }

                              // 🔎 필터링 적용
                              logger.i(searchKeyword);
                              List<MoneyTransaction> filteredTransactions = extraTransactionDatas.where((transaction) {
                                DateTime txDate = format.parse(transaction.transactionTime);
                                bool matchesDate = (startDate == null || !txDate.isBefore(startDate!)) &&
                                                    (endDate == null || !txDate.isAfter(endDate!));
                                bool matchesKeyword = transaction.goods.contains(searchKeyword);
                                return matchesDate && matchesKeyword;
                              }).toList();
                              return  Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      // controller: scrollDialogController,
                                      shrinkWrap: true,
                                      itemCount: filteredTransactions.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: Icon(
                                            selectedTransactionData.contains(filteredTransactions[index].id)
                                                ? Icons.check_circle
                                                : Icons.check_circle_outline,
                                            color: selectedTransactionData.contains(filteredTransactions[index].id)
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                          title: Text(filteredTransactions[index].goods),
                                          subtitle: Text(filteredTransactions[index].transactionTime),
                                          onTap: () {
                                            setState(() {
                                              if (selectedTransactionData.contains(filteredTransactions[index].id)) {
                                                selectedTransactionData.remove(filteredTransactions[index].id);
                                                localselectedTransactionData.remove(filteredTransactions[index]);
                                              } else {
                                                selectedTransactionData.add(filteredTransactions[index].id!);
                                                localselectedTransactionData.add(filteredTransactions[index]);
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
                    ],
                  ),
                )
              );
            }
          )
        );
      }
    ).then((selectedData) {
      if(selectedData != null) {
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
            fetchChartMap();
          } catch (e) {
            logger.e(e);
          }
        });
      }
    });
  }

  void updateDataToDatabase(List<Map<String, dynamic>> jsonfyTableData) {
    final ExtraBudgetGroup updatedGroup = ExtraBudgetGroup(
      id: widget.id, 
      dataList: {
        'title':title,
        'backGroundColor': titleColor.value,
        'selectedTransactionData': selectedTransactionData.toSet().toList(),
        'tableData': jsonfyTableData,
      }
    );
    logger.d(updatedGroup.dataList);
    DatabaseAdmin().updateExtraGroup(updatedGroup);
  }
}
