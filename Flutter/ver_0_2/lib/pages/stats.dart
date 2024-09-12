import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:logger/logger.dart';
import 'package:ver_0_2/pages/stats_book.dart';
// import 'package:ver_0_2/pages/stats_invest.dart';
import 'package:ver_0_2/widgets/drawer_end.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
// import 'package:ver_0_2/widgets/models/current_holdings.dart';
import 'package:ver_0_2/widgets/models/extra_budget_group.dart';

Logger logger = Logger();

class StatisticsView extends StatelessWidget {
  const StatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('통계'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        endDrawer: const AppDrawer(),
        body: const NestedTabBarBook())
      ;
    //   DefaultTabController(
    //   length: 2,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('통계'),
    //       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    //     ),
    //     endDrawer: const AppDrawer(),
    //     body: const Column(
    //       children: [
    //         TabBar(
    //           tabs: <Widget>[
    //             Tab(text: '가계부'),
    //             Tab(text: '자산관리'),
    //           ]
    //         ),
    //         Expanded(
    //           child: TabBarView(
    //             children: <Widget>[
    //               NestedTabBarBook(),
    //               NestedTabBarInvest(),
    //             ],
    //           ),
    //         )
    //       ]
    //     ),
    //   ),
    // );
  }
}

class NestedTabBarBook extends StatefulWidget {
  const NestedTabBarBook({super.key});

  @override
  State<NestedTabBarBook> createState() => _NestedTabBarBookState();
}

class _NestedTabBarBookState extends State<NestedTabBarBook> with SingleTickerProviderStateMixin {
  Logger logger = Logger();
  int currentIndex = 0;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            TabBar(
              tabs: const <Widget>[
                Tab(text: '월간 소비'),
                Tab(text: '월간 예산'),
                Tab(text: '연간 소비'),
                Tab(text: '특별 예산'),
              ],
              onTap: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            if (currentIndex < 3) 
            Column(
              children: [
                DateMonthBar(
                  year: year,
                  month: month,
                  yearBack: () {
                    setState(() {
                      year = year - 1;
                    });
                  },
                  monthBack: currentIndex !=2 ? () {
                    setState(() {
                      month = month - 1;
                      if(month == 0) {
                        month = 12;
                        year = year - 1;
                      }
                    });
                  } : null,
                  monthForward: currentIndex !=2 ? () {
                    setState(() {
                      month = month + 1;
                      if(month == 13) {
                        month = 1;
                        year = year + 1;
                      }
                    });
                  } : null,
                  yearForward: () {
                    setState(() {
                      year = year + 1;
                    });
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  MonthlyConsumePage(key: UniqueKey(), year: year, month: month),
                  BudgetSettingPage(key: UniqueKey(), year: year, month: month),
                  YearlyConsumePage(key: UniqueKey(), year: year),
                  const ExtraBudgetGrid(),
                ],
              ),
            )
          ]
        ),
      ),
    );
  }
}

///특별 예산 관리 페이지
class ExtraBudgetGrid extends StatefulWidget {
  const ExtraBudgetGrid({super.key});

  @override
  State<ExtraBudgetGrid> createState() => _ExtraBudgetGridState();
}

class _ExtraBudgetGridState extends State<ExtraBudgetGrid> {
  final List<String> _buttonSettingItems = ['색상 변경', '제목 변경', '그룹 삭제'];
  final TextEditingController _textController = TextEditingController();
  List<ExtraBudgetGroup> buttonTexts = [];

  @override
  void initState() {
    super.initState();
    fetchDatas();
  }

  Future<void> fetchDatas() async{
    List<ExtraBudgetGroup> fetchGroupData = [];
    fetchGroupData = await DatabaseAdmin().getAllExtraGroupDatas();
    if(mounted) {
      setState(() {
        buttonTexts = fetchGroupData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
              TextButton(
                onPressed: _showDialog,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('특별 예산 그룹 항목 추가하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    Icon(Icons.add_circle_outlined),
                  ],
                ),
              ),
            const Divider(),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: List.generate( 
                buttonTexts.length,
                (index) {
                  return _gridButton(index, buttonTexts[index].dataList!['title'], buttonTexts[index].dataList!['backGroundColor']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridButton(int index, String title, int primaryColors) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: SizedBox(
              width: min(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.height * 0.4),
              height: min(MediaQuery.of(context).size.width * 0.4, MediaQuery.of(context).size.height * 0.4),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => ExtraBudgetGroupDetail(id: buttonTexts[index].id!),
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
                    )
                  )
                  .then((result) {
                    setState(() {
                      fetchDatas();
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)) ,
                  backgroundColor: Color(primaryColors),
                ),
                child: Align(
                  alignment: const Alignment(-1,-0.9),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0, 
                      color: (Color(primaryColors).red +Color(primaryColors).green + Color(primaryColors).blue) /3 > 127
                        ?Colors.black : Colors.white),
                    textAlign: TextAlign.center
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 25,
            child: DropdownButton(
              onChanged: (String? newValue) {
                if (newValue == "색상 변경") {
                  showColorDialog(index, Color(primaryColors));
                }
                /// 그룹 제목 변경
                if (newValue == "제목 변경") {
                  _textController.text = buttonTexts[index].dataList!['title'];
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('제목 변경'),
                        content: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(hintText: '그룹 이름 설정'),
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
                                if (_textController.text != '') {
                                  buttonTexts[index].dataList!['title'] =  _textController.text;
                                  updateGroupDataToDatabase(buttonTexts[index]);
                                  fetchDatas();
                                }
                                _textController.clear();
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('변경'),
                          ),
                        ],
                      );
                    },
                  );
                }
                ///그룹 삭제
                if (newValue == "그룹 삭제") {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('그룹 삭제'),
                        content: const Text('선택한 그룹을 삭제하시겠습니까?'),
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
                                deleteGroupFormListDatabase(buttonTexts[index].id!);
                                fetchDatas();
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('삭제'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              items: _buttonSettingItems.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              underline: Container(
                color: Colors.transparent,
              ),
              icon: const Icon(Icons.more_vert)
            )
          ),
        ],
      )
    );
  }
  void _showDialog() {
    _textController.text ='New Group${buttonTexts.length+1}';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새로운 그룹 추가'),
          content: TextField(
            controller: _textController,
            decoration: const InputDecoration(hintText: '그룹 이름 설정'),
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
                  if (_textController.text != '') {
                    Map<String,dynamic> newGroup = {'title':_textController.text,'backGroundColor': Random().nextInt(0xffffffff)};
                    insertNewGorupToDatabase(newGroup);
                    fetchDatas();
                  }
                  _textController.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );
  }

  void showColorDialog(int index, Color currentColor) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                setState(() {
                  pickerColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('확인'),
              onPressed: () {
                setState(() {
                   buttonTexts[index].dataList!['backGroundColor'] = pickerColor.value;
                   updateGroupDataToDatabase(buttonTexts[index]);
                   fetchDatas();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  void insertNewGorupToDatabase(Map<String, dynamic> data) {
    final ExtraBudgetGroup newGroup = ExtraBudgetGroup(
      dataList: data,
    );

    DatabaseAdmin().insertExtraBugetSettingTable(newGroup);
  }

  void updateGroupDataToDatabase(ExtraBudgetGroup updatedGroup) {
    DatabaseAdmin().updateExtraGroup(updatedGroup);
  }

  void deleteGroupFormListDatabase(int id) {
    DatabaseAdmin().deleteExtraGroup(id);
  }
}

// class NestedTabBarInvest extends StatefulWidget {
//   const NestedTabBarInvest({super.key});

//   @override
//   State<NestedTabBarInvest> createState() => _NestedTabBarInvestState();
// }

// class _NestedTabBarInvestState extends State<NestedTabBarInvest> {
//   List<Holdings> currentHoldings = [];
//   List<String> investCategories = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchHoldings();
//   }

//   Future<void> _fetchHoldings() async {
//     List<Holdings> fetchedHoldings = await DatabaseAdmin().getCurrentHoldInvestments();
//     setState(() {
//       currentHoldings = fetchedHoldings;
//       investCategories = currentHoldings.map((holding) => holding.investcategory).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         body: Column(
//           children: [
//             const TabBar(
//               tabs: <Widget>[
//                 Tab(text: '현재 투자 목록'),
//                 Tab(text: '수익률 현황'),
//               ]
//             ),
//             Expanded(
//               child: TabBarView(
//                 children: <Widget>[
//                   InvestHolingsPage(currentHoldings: currentHoldings, investCategories: investCategories),
//                   const Center(child: Text("차후 업데이트", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),)
//                   // const BarchartHorizontal(),
//                 ],
//               ),
//             )
//           ]
//         ),
//       ),
//     );
//   }
// }


