import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ver_0_2/colorsholo.dart';
import 'package:ver_0_2/pages/book_add.dart';
import 'package:ver_0_2/widgets/drawer_end.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/synchro_line_charts.dart';
import 'package:ver_0_2/widgets/synchro_data_grid.dart';

class Book extends StatefulWidget {
  const Book({super.key});
  
  @override
  State<Book> createState() => _BookState();
}

class _BookState extends State<Book> {
  Logger logger = Logger();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _sliverListKey = GlobalKey();
  PersistentBottomSheetController? bottomButtonController;
  // bool _isVisible = true; // 플로팅 버튼이 보이는지 여부를 나타내는 변수
  int initialFilterState = 0;
  double  itemSize = 110.0;
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  List<MoneyTransaction> transactions = [];
  Set<int> selectedIds = {};
  bool isSelectionMode = false;
  List<String> filterValue = ['소비', '수입'];
  String? transactionFilter = '기본';
  String? lastTopDatetime;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchTransactions() async {
    List<MoneyTransaction> fetchedTransactions = await DatabaseAdmin().getTransactionsByMonth(year, month);
    // 날짜 형식에 맞는 DateFormat 생성
    DateFormat format = DateFormat("yyyy년 MM월 dd일'T'HH:mm");

    fetchedTransactions.sort((a, b) {
      DateTime dateA = format.parse(a.transactionTime); // String -> DateTime 변환
      DateTime dateB = format.parse(b.transactionTime); // String -> DateTime 변환
      return dateA.compareTo(dateB); // DateTime으로 정렬
    });
    setState(() {
      transactions = fetchedTransactions;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  String formatterK(num number) {
    String preproNumber;
    if(number % 1 == 0) {
      preproNumber = number.toStringAsFixed(0);
    } else {
      preproNumber =  number.toString();
    }

    String newText = preproNumber.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (newText.isEmpty) return "0";

    final double value = double.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(value);

    return formattedText;
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward || _scrollController.offset == _scrollController.position.minScrollExtent) {
      DateTime datetiemInitValue = DateFormat('yyyy년 MM월 dd일THH:mm').parse(transactions[0].transactionTime);
      String initTopDatetime= DateFormat('yyyy년 MM월 dd일').format(datetiemInitValue);
      lastTopDatetime = initTopDatetime;
      // setState(() {
      //   _isVisible = true;
      // });
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_scrollController.hasClients) {        
        int currentTopIndex = 0;
        final sliverList = _sliverListKey.currentContext?.findRenderObject();
        if (sliverList is RenderSliverList) {
          // 스크롤 위치와 아이템의 화면 내 위치를 비교
          double viewportOffset = _scrollController.offset;
          RenderBox? child = sliverList.firstChild;
          int? topIndex;

          while (child != null) {
            final double itemPosition = sliverList.childScrollOffset(child)!;
            // final double itemPosition = sliverList.childMainAxisPosition(child);
            if (itemPosition >= viewportOffset) {
              topIndex = sliverList.indexOf(child);
              break;
            }
            child = sliverList.childAfter(child);
          }

          if (topIndex != null && topIndex != currentTopIndex) {
            setState(() {
              currentTopIndex = topIndex!;
            });
          }
          DateTime datetiemValue = DateFormat('yyyy년 MM월 dd일THH:mm').parse(transactions[currentTopIndex].transactionTime);
          String currentTopDatetime= DateFormat('yyyy년 MM월 dd일').format(datetiemValue);
          lastTopDatetime ??= currentTopDatetime;//null이면 값 할당

          if (lastTopDatetime != currentTopDatetime) {
            lastTopDatetime = currentTopDatetime;

            // Toast 메시지 표시
            Fluttertoast.cancel();
            _showDateToast('$lastTopDatetime');
          }
        }
      }
      // setState(() {
      //   _isVisible = false;
      // });
    }
  }


  void _showDateToast(String message) {   
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.green.shade400,
    );
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
            child: 
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  key: _sliverListKey,
                  delegate: SliverChildBuilderDelegate((context, index)  {
                    MoneyTransaction transaction = transactions[index];
                    if (!filterValue.contains(transactions[index].categoryType)) {
                      return const SizedBox.shrink();
                    }
                    final isSelected = selectedIds.contains(transaction.id);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: transaction.categoryType == '소비' ? [Colors.red.shade200, Colors.red.shade50] : transaction.categoryType == '수입' ? [Colors.blue.shade200, Colors.blue.shade50] : [Colors.grey.shade200, Colors.grey.shade50],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: isSelectionMode
                          ? () => toggleSelection(transaction.id!)
                          : () {
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
                            }
                          );
                        },
                        onDoubleTap: isSelectionMode
                          ? ()  => toggleSelectionAll()
                          : null,
                        onLongPress: () {
                          enterSelectionMode();
                          toggleSelection(transaction.id!);
                        },
                        child: TransactionTileItem(
                          title: transaction.goods,
                          category: transaction.category,
                          amount: AutoSizeText(formatterK(transaction.categoryType == '소비' ? transaction.amount * -1 : transaction.amount), style: TextStyle(fontSize: 20, color: transaction.categoryType == '소비' && transaction.amount > 0 ? Colors.grey : Colors.black), maxLines: 1),
                          memoWidget: buildMemoText(transaction.description!),
                          headIcon: isSelectionMode
                          ? Icon(
                            isSelected ? Icons.check : null,
                            color: isSelected ? Colors.green : Colors.transparent,
                          )
                          : null,
                        ),
                      ),
                    );
                  }, childCount: transactions.length),
                )
              ]
            )
          ),
          if (transactions.isEmpty)
          const Center(child: Text('금월 데이터가 없습니다')),
        ]
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'filter-floating',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('내역 필터'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<String>(
                              value: '기본',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('기본'),
                              subtitle: const Text('소비 + 수입'),
                            ),
                            RadioListTile<String>(
                              value: '소비',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('소비'),
                              subtitle: const Text(
                                  '소비 내역만'),
                            ),
                            RadioListTile<String>(
                              value: '수입',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('수입'),
                              subtitle: const Text(
                                  '수입 내역만'),
                            ),
                            RadioListTile<String>(
                              value: '전체',
                              groupValue: transactionFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  transactionFilter = value;
                                });
                              },
                              title: const Text('전체'),
                              subtitle: const Text(
                                  '소비 + 수입 + 이체'),
                            ),
                          ],
                        );
                      },
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
                              switch (transactionFilter) {
                                case '기본' :
                                  filterValue = ['소비', '수입'];
                                  break;
                                case '소비' :
                                  filterValue = ['소비'];
                                  break;
                                case '수입' :
                                  filterValue = ['수입'];
                                  break;
                                case '전체' :
                                  filterValue = ['소비', '수입', '이체'];
                                  break;
                              }
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('확인'),
                        ),
                    ],
                  );
                },
              );
            },
            tooltip: '표시 내역 필터',
            child: transactionFilter == '기본' ? const Icon(Icons.filter_alt_outlined) : const Icon(Icons.filter_alt),
          ),
          const SizedBox(height: 8.0),
          // Visibility(
          //   visible: true,
          //   child:  
          FloatingActionButton(
            heroTag: 'ADD-floating',
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
          // ),
        ],
      ),
    );
  }

  void showTileAdminButton() {
    bottomButtonController = showBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               SizedBox (
                width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
                  onPressed: exitSelectionMode,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('취소'),
                ),
              ),
              SizedBox (
                width: MediaQuery.of(context).size.width * 0.3,
                child:ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('삭제 확인'),
                          content: const Text('데이터를 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteDatasFromDatabase();
                                Navigator.pop(context); // Close the dialog
                              },
                              child: const Text('삭제'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('삭제', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
      enableDrag: false,
    );
  }

  void deleteDatasFromDatabase() {
    for (var id in selectedIds) {
      DatabaseAdmin().deleteMoneyTransaction(id);
    }

    setState(() {
      transactions.removeWhere((transaction) => selectedIds.contains(transaction.id));
      selectedIds.clear();
      isSelectionMode = false;
    });

    bottomButtonController?.close();
  }

  
  void toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
    if (selectedIds.isEmpty) exitSelectionMode();
  }

  void toggleSelectionAll() {
    setState(() {
    // 현재 페이지의 거래 ID만 사용
    List<int> currentPageIds = (transactions).map((tx) => tx.id!).toList();

    if (selectedIds.containsAll(currentPageIds)) {
      // 현재 페이지의 모든 거래가 선택된 상태라면 선택 해제
      selectedIds.removeAll(currentPageIds);
    } else {
      // 현재 페이지의 거래를 모두 선택
      selectedIds.addAll(currentPageIds);
    }
  });

  if (selectedIds.isEmpty) {
    exitSelectionMode();
  }
  }

  void enterSelectionMode() {
    setState(() {
      isSelectionMode = true;
    });
    showTileAdminButton();
  }

  void exitSelectionMode() {
    setState(() {
      selectedIds.clear();
      isSelectionMode = false;
    });
    bottomButtonController?.close(); // Close the bottom sheet
  }

  Widget buildMemoText(String memo) {
    final RegExp tagPattern = RegExp(r'#[ㄱ-ㅎ가-힣0-9a-zA-Z_]+');
    TextStyle normalStyle = const TextStyle(color: Colors.black, fontSize: 14);
    // final RegExp tagPattern = RegExp(r'^#\w+[#태그#]');
    final String inputText = memo;
    List<Text> spans = [];
    List<TextButton> buttons = [];
    int lastMatchEnd = 0;
    // logger.d(tagPattern.allMatches(inputText).map((match) => match.group(0)).toList());
    tagPattern.allMatches(inputText).forEach((match) {
      if (match.start > lastMatchEnd) {
        String substring = inputText.substring(lastMatchEnd, match.start);
        if (substring.trim().isNotEmpty) {  // 공백만 있는지 확인
          spans.add(Text(
            substring,
            style: normalStyle,
          ));
        }
      }
      buttons.add(TextButton.icon(
        icon: const Icon(Icons.tag, size: 16,),
        onPressed: (){
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => TagStatViewPage(tagName: inputText.substring(match.start, match.end)),
              transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
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
        label: Text(inputText.substring(match.start, match.end).replaceAll(RegExp(r'#'),''), style: const TextStyle(fontSize: 14),),    
        style: TextButton.styleFrom(
          backgroundColor: HoloColors.otonoseKanade.withOpacity(0.5), // 배경색
          foregroundColor: HoloColors.nekomataOkayu, // 텍스트 색상
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // 둥근 모서리
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold), // 텍스트 스타일
          // padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0), // 버튼 내부 여백
        ), 
      ));
      lastMatchEnd = match.end;
    });
    if (lastMatchEnd < inputText.length) {
      spans.add(Text(
        inputText.substring(lastMatchEnd),
        style: normalStyle,
      ));
    }    
    return Wrap(
      // mainAxisSize: MainAxisSize.min,
      spacing: 4.0, // 위젯 간의 가로 간격
      runSpacing: 4.0, // 줄 간의 간격
      children: [
        ...buttons, // 태그 버튼 묶음
        ...spans, // 일반 텍스트 묶음
      ],
    );
  }
}


class TransactionTileItem extends StatelessWidget {
  final Widget? headIcon;
  final String title;
  final String category;
  final Widget amount;
  final Widget memoWidget;
  final void Function()? onTap;
  final void Function()? onLongPress;

  const TransactionTileItem({
    super.key,
    required this.headIcon,
    required this.title,
    required this.category,
    required this.amount,
    required this.memoWidget,
    this.onTap,
    this.onLongPress,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if(headIcon != null)
                Expanded(
                  flex: 1,
                  child: headIcon!,
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                        Text(
                          category,
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: amount,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if(headIcon != null)
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 4,
                    child: memoWidget,
                  )
                ]
              )
            ),
          ],
        ),
      ),
    );
  }
}

class TagStatViewPage extends StatelessWidget {
  final String tagName;
  const TagStatViewPage({
    super.key,
    required this.tagName
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$tagName 통계'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5,),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LineChartsByYearMonthTag(
                key: UniqueKey(),
                tagName: tagName
              ),
            ),
          ),
          const SizedBox(height: 30),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5,),
              child: TagDataGrid(
                key: UniqueKey(),
                tagName: tagName
              ),
            ),
          ),
        ],
      )
    );
  }
}
