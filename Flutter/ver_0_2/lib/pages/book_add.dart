import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ver_0_2/colorsholo.dart';
import 'package:ver_0_2/widgets/date_picker.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
// import 'package:ver_0_2/widgets/models/bank_account.dart';
// import 'package:ver_0_2/widgets/models/card_account.dart';
import 'package:ver_0_2/widgets/models/transaction_category.dart';

class BookAdd extends StatefulWidget {
  final MoneyTransaction? moneyTransaction;
  const BookAdd({this.moneyTransaction, super.key});

  @override
  State<BookAdd> createState() => _BookAddState();
}

class _BookAddState extends State<BookAdd> {
  Logger logger = Logger();
  MoneyTransaction? moneyTransactionOrigin;
  final FocusNode _focusAmountNode = FocusNode();
  final FocusNode _focusMemoNode = FocusNode();
  UnfocusDisposition disposition = UnfocusDisposition.scope;
  PersistentBottomSheetController? _bottomSheetController;
  final GlobalKey<FormState> _formBookAddKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldBookAddKey = GlobalKey<ScaffoldState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  // final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountdisplayController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  final TextEditingController _targetgoodsController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String currentCategory = "소비";
  bool timeShow = false;
  bool iscredit = false;
  late String _pageType;
  // bool _isMemoEditing = false;
  TextStyle normalStyle = const TextStyle(color: Colors.black, fontSize: 20);
  TextStyle tagStyle = TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20, backgroundColor: Colors.yellow.shade100);
  List<String> allTags = [];
  List<String> suggestedTags = [];
  List<String> yearlyExpenseCategory = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    if(widget.moneyTransaction != null) {
      _pageType = "수정";
      // _isMemoEditing = false;
    } else {
      _pageType = "입력";
      // _isMemoEditing = true;
    }
    _focusAmountNode.addListener(() {
      if (_focusAmountNode.hasFocus) {
        // 키보드가 올라왔을 때 BottomSheet를 띄움
        _bottomSheetController = _scaffoldBookAddKey.currentState?.showBottomSheet((context) => buildCustomKeyboardActions());
      } else {
        // 키보드가 내려갈 때 BottomSheet를 닫음
        _bottomSheetController?.close();
      }
    });
    _focusMemoNode.addListener(() {
      if (!_focusMemoNode.hasFocus) {
        if(_overlayEntry != null) {
          _overlayEntry!.remove();
          _overlayEntry = null;
        }
      } 
    });
    _initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    _focusAmountNode.dispose();
    _focusMemoNode.dispose();
    _memoController.dispose();
    super.dispose();
  }


  Future<void> _initializeControllers() async {
  // 페이지가 초기화될 때 받아온 정보를 사용하여 상태를 업데이트합니다.
    if (widget.moneyTransaction != null) {
      // logger.d(widget.moneyTransaction!.id);
      moneyTransactionOrigin = await DatabaseAdmin().getTransactionsFromDisplayer(widget.moneyTransaction!);
      _idController.text = moneyTransactionOrigin!.id.toString();
      List<String> parts = moneyTransactionOrigin!.transactionTime.split('T');
      _dateController.text = parts[0].trim();
      _timeController.text = parts[1].trim();
      // _accountController.text = moneyTransactionOrigin!.account.toString();
      _amountController.text = moneyTransactionOrigin!.amount.toString();
      _amountdisplayController.text = _thousandsFormmater(_amountController.text);
      _targetgoodsController.text = moneyTransactionOrigin!.goods;
      _categoryController.text = moneyTransactionOrigin!.category;
      _installmentController.text = moneyTransactionOrigin!.installation.toString();
      // logger.d(moneyTransactionOrigin!.categoryType);
      currentCategory = moneyTransactionOrigin!.categoryType;
      _memoController.text = moneyTransactionOrigin!.description ?? '';
      iscredit = moneyTransactionOrigin!.credit;
    } else {
      _dateController.text = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());
      _timeController.text = '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}';
      _amountController.text = "-0";
      _amountdisplayController.text = _thousandsFormmater(_amountController.text);
    }
    allTags = await DatabaseAdmin().getTransactionsTags();
    yearlyExpenseCategory = (await DatabaseAdmin().getYearlyExpenseCategories()).itemList ?? [];
    setState(() {
      
    });
    // logger.d(allTags);
  }

  String _thousandsFormmater(String numberText) {
    String newText = numberText.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (newText.isEmpty) return "0";

    final double value = double.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(value);

    return formattedText;
  }

  // 태그 추천 표시
  void _showTagSuggestions(String tagFragment) {
    final RenderBox renderBox = _focusMemoNode.context!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final pattern = RegExp('^${RegExp.escape(tagFragment)}', caseSensitive: false);
    // 태그 추천 목록 업데이트
    suggestedTags = allTags
        // .where((tag) => RegExp(RegExp.escape(input), caseSensitive: false).hasMatch(tag))
        .where((tag) =>  pattern.hasMatch(tag))
        .toList();

    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (suggestedTags.isNotEmpty) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: 16.0,
          right: 16.0,
          top: position.dy + renderBox.size.height + 8.0,
          // top: MediaQuery.of(context).size.height / 2 - 100,
          child: Material(
            elevation: 4.0,
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 200.0, // Set the maximum height for the list
              ),
              child:ListView.builder(
                shrinkWrap: true,
                itemCount: suggestedTags.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestedTags[index]),
                    onTap: () {
                      _insertTagIntoText(suggestedTags[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  // 태그를 텍스트에 삽입
  void _insertTagIntoText(String tag) {
    final text = _memoController.text;
    final cursorPosition = _memoController.selection.baseOffset;

    // 현재 커서 위치까지의 텍스트 분리
    final beforeCursor = text.substring(0, cursorPosition);
    final afterCursor = text.substring(cursorPosition);

    final matches = RegExp(r'#', unicode: true).allMatches(beforeCursor);
    final lastMatch = matches.isNotEmpty ? matches.last : null;
    String updatedBeforeCursor;
    if (lastMatch != null) {
    // 마지막 태그를 새 태그로 교체
      updatedBeforeCursor = beforeCursor.substring(0, lastMatch.start+1);
    } else {
      // 마지막 태그가 없는 경우, 새 태그를 추가
      updatedBeforeCursor = beforeCursor;
    }

    // 태그 삽입 및 커서 위치 조정
    final newText = '$updatedBeforeCursor${tag.replaceAll(RegExp(r'#'), '')} $afterCursor';
    _memoController.text = newText;

    // 커서를 태그 바로 뒤로 이동
    _memoController.selection = TextSelection.fromPosition(
      TextPosition(offset: updatedBeforeCursor.length + tag.length),
    );

    // 추천 목록 닫기
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 입력 중 태그 추천 처리
  void _onTextChanged(String value) {
    final cursorPosition = _memoController.selection.baseOffset;

    if (cursorPosition <= 0 || cursorPosition > value.length) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    // 현재 커서 앞부분 텍스트 추출
    final beforeCursor = value.substring(0, cursorPosition);

    // 태그가 감지되면 추천 목록 표시
    final tagMatch = RegExp(r'#[^\s]*$').firstMatch(beforeCursor);
    if (tagMatch != null) {
      final tagFragment = tagMatch.group(0)!; // 현재 태그 부분
      _showTagSuggestions(tagFragment);
    } else {
      // 태그가 없으면 추천 닫기
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        _focusAmountNode.unfocus(disposition: disposition);
        _bottomSheetController?.close();
        // Navigator.pop(context);
      }, 
      child: Scaffold(
        key: _scaffoldBookAddKey,
        appBar: AppBar(
          title: AutoSizeText('가계부 $_pageType', maxLines: 1),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10,10,40,10),
          child: Form(
            key: _formBookAddKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    categoryRadioButton(
                      '소비', HoloColors.ookamiMio,
                      () {
                        setState(() {
                          currentCategory = "소비";
                          // _amountController.text = "-0";
                          _amountdisplayController.text = _thousandsFormmater(_amountController.text);
                        });
                      }
                    ),
                    categoryRadioButton(
                      '수입', HoloColors.ceresFauna,
                      () {
                        setState(() {
                          currentCategory = "수입";
                          // _amountController.text = "0";
                          _amountdisplayController.text = _thousandsFormmater(_amountController.text);
                        });
                      }
                    ),
                    categoryRadioButton(
                      '이체', HoloColors.shiroganeNoel,
                      () {
                        setState(() {
                          currentCategory = "이체";
                        });
                      }
                    ),
                  ],
                ),
                const SizedBox(height: 16.0), // Add spacing between rows and buttons
                // Date, String, Int, String, String Fields
                buildDateTimeRow("날짜", _dateController, _timeController),
                amountRow("거래금액", _amountdisplayController),
                if(iscredit)
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText("할부 개월수", maxLines: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _installmentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          suffix: Text('개월')
                        ),
                      ),
                    ),
                  ],
                ),
                buildTextRow("거래대상", _targetgoodsController),
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText("거래분류", maxLines: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        readOnly: true,
                        controller: _categoryController,
                        onTap: () {
                          _showCategoryModal(context);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("메모"),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _memoController,
                            focusNode: _focusMemoNode,
                            onChanged: _onTextChanged,
                          ),
                        ]
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16.0), // Add spacing between buttons
                if(_pageType == "수정")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Handle Cancel button press
                        _bottomSheetController?.close();
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formBookAddKey.currentState?.validate() ?? false) {
                          // Save data when Save button is pressed
                          _bottomSheetController?.close();
                          await updateDataToDatabase();
                          if(context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      child: const Text('수정'),
                    ),
                  ],
                ),
                if(_pageType == "입력")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Handle Cancel button press
                        _bottomSheetController?.close();
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formBookAddKey.currentState?.validate() ?? false) {
                          // Save data when Save button is pressed
                          _bottomSheetController?.close();
                          await insertDataToDatabase();
                          if(context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      },
                      child: const Text('저장'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }


  //----------------------------------------------------------------------------//


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
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5), // 원하는 최대 높이로 설정
              child:SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      ...fetchedCategorys.expand((category) {
                      if (category.name == currentCategory) {
                        return category.itemList!.map((item) {
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              setState(() {
                                _categoryController.text = item;
                                Navigator.pop(context);
                                // if( _pageType == "수정") {
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return AlertDialog(
                                //         title: const Text('삭제 확인'),
                                //         content: const Text('같은 대상을 일괄 변경하시겠습니까?'),
                                //         actions: [
                                //           TextButton(
                                //             onPressed: () {
                                //               Navigator.pop(context);
                                //             },
                                //             child: const Text('취소'),
                                //           ),
                                //           TextButton(
                                //             onPressed: () {
                                //               Navigator.pop(context);
                                //               DatabaseAdmin().updateCategorySearchAllTable(_targetgoodsController.text,item,currentCategory, double.parse(_amountController.text) > 0);
                                //             },
                                //             child: const Text('확인'),
                                //           ),
                                //         ],
                                //       );
                                //     },
                                //   );
                                // } 
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

  /// 커스텀 키보드 액션 버튼들 구성
  Widget buildCustomKeyboardActions(){
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _changeAmountOutlinedButton("±", () {
                String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
                if (amountText.startsWith('-')) {
                  amountText = '-${amountText.substring(1).replaceAll('-', '')}';
                } else {
                  amountText = amountText.replaceAll('-', '');
                }
                _amountController.text = amountText;
                _amountController.text = (double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) * -1).toStringAsFixed(0) : (double.parse(_amountController.text) * -1).toString();
                _amountdisplayController.text = _thousandsFormmater(_amountController.text);
              }),
              _changeAmountOutlinedButton("1,000", () {
                String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
                if (amountText.startsWith('-')) {
                  amountText = '-${amountText.substring(1).replaceAll('-', '')}';
                } else {
                  amountText = amountText.replaceAll('-', '');
                }
                _amountController.text = amountText;
                _amountController.text = _amountController.text.startsWith('-') 
                  ? ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) - 1000).toStringAsFixed(0) : (double.parse(_amountController.text) - 1000).toString())
                  : ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) + 1000).toStringAsFixed(0) : (double.parse(_amountController.text) + 1000).toString());
                _amountdisplayController.text = _thousandsFormmater(_amountController.text);
              }),
              _changeAmountOutlinedButton("5,000", () {
                String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
                if (amountText.startsWith('-')) {
                  amountText = '-${amountText.substring(1).replaceAll('-', '')}';
                } else {
                  amountText = amountText.replaceAll('-', '');
                }
                _amountController.text = amountText;
                _amountController.text = _amountController.text.startsWith('-')
                  ? ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) - 5000).toStringAsFixed(0) : (double.parse(_amountController.text) - 5000).toString())
                  : ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) + 5000).toStringAsFixed(0) : (double.parse(_amountController.text) + 5000).toString());
                _amountdisplayController.text = _thousandsFormmater(_amountController.text);
              }),
              _changeAmountOutlinedButton("10,000", () {
                String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
                if (amountText.startsWith('-')) {
                  amountText = '-${amountText.substring(1).replaceAll('-', '')}';
                } else {
                  amountText = amountText.replaceAll('-', '');
                }
                _amountController.text = amountText;
                _amountController.text = _amountController.text.startsWith('-') 
                  ? ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) - 10000).toStringAsFixed(0) : (double.parse(_amountController.text) - 10000).toString())
                  : ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) + 10000).toStringAsFixed(0) : (double.parse(_amountController.text) + 10000).toString());
                _amountdisplayController.text = _thousandsFormmater(_amountController.text);
              }),
              _changeAmountOutlinedButton("100,000", () {
                String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
                if (amountText.startsWith('-')) {
                  amountText = '-${amountText.substring(1).replaceAll('-', '')}';
                } else {
                  amountText = amountText.replaceAll('-', '');
                }
                _amountController.text = amountText;
                _amountController.text = _amountController.text.startsWith('-')
                  ? ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) - 100000).toStringAsFixed(0) : (double.parse(_amountController.text) - 100000).toString())
                  : ((double.parse(_amountController.text) % 1 == 0) ? (double.parse(_amountController.text) + 100000).toStringAsFixed(0) : (double.parse(_amountController.text) + 100000).toString());
                _amountdisplayController.text = _thousandsFormmater(_amountController.text);
              }),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  /// 키보드 위 간단 숫자 입력 버튼
  Widget _changeAmountOutlinedButton(String text, Function() onPressed) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 너비에 따라 폰트 크기 조정
          double fontSize = constraints.maxWidth * 0.15; // 예: 최대 너비의 15%
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
                    return BorderSide(color: Colors.green.withValues(alpha: 0.9));
                  },
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget buildTextRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget amountRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label), 
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller,
              focusNode: _focusAmountNode,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
              // onChanged: (String value),
              decoration: InputDecoration(
                suffix: IconButton(
                  onPressed: (){
                    setState(() {
                      _amountController.text = "0";
                      _amountdisplayController.text = _thousandsFormmater(_amountController.text);
                    });
                  },
                  icon: const Icon(Icons.backspace_outlined)
                ),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,// Increased font size
              ),
              inputFormatters: [ThousandsSeparatorInputFormatter()],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: iscredit,
                  onChanged: (bool? value) {
                    setState(() {
                      iscredit = value!;
                    });
                  },
                ),
                const Text('신용 여부')
              ],
            )
          ),
        ],
      ),
    );
  }

  Widget buildDateTimeRow(String label, TextEditingController dateController, TextEditingController timeController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  flex: 6,
                  fit: FlexFit.loose,
                  child: DatePicker(
                    controller: dateController,
                    tryValidator: true,
                  ),
                ),
                if(timeShow)
                Flexible(
                  flex: 4,
                  fit: FlexFit.loose,
                  child: TimePicker(
                    onCancelTimeSet: () {
                      setState(() {
                        timeShow = false;
                      });
                    },
                    controller: timeController,
                    tryValidator: true,
                  ),
                ),
                if(!timeShow)
                Flexible(
                  flex: 6,
                  fit: FlexFit.loose,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: timeShow,
                        onChanged: (bool? value) {
                          setState(() {
                            timeShow = value!;
                          });
                        },
                      ),
                      const Text('시간 설정하기')
                    ],
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryRadioButton(String text, Color color, void Function() onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all<Size>(const Size(120, 30)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (currentCategory == text) {
              return color.withValues(alpha: 0.4);
            }
            return Colors.transparent;
          },
        ),
        side : WidgetStateProperty.resolveWith<BorderSide>(
          (Set<WidgetState> states) {
            if (currentCategory == text) {
              return const BorderSide(color: Colors.transparent);
            }
            return BorderSide(color: color.withValues(alpha: 0.9));
          },
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0, // Increased font size
        ),
      ),
    );
  }

  Future<void> insertDataToDatabase() async {
    String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (_amountController.text.startsWith('-')) {
      amountText = '-${amountText.substring(1).replaceAll('-', '')}';
    } else {
      amountText = amountText.replaceAll('-', '');
    }
    _amountController.text = amountText;
    if(!timeShow) {
      _timeController.text = '12:00';
    }

      int installmentMonths = int.tryParse(_installmentController.text) ?? 1;
      final MoneyTransaction transaction = MoneyTransaction(
        transactionTime: '${_dateController.text}T${_timeController.text}', // 여기서는 현재 시간을 사용할 수 있습니다. 
        // account: _accountController.text,
        // amount: currentCategory == "소비"? double.parse(_amountController.text).abs()*-1 : currentCategory == "수입"? double.parse(_amountController.text).abs() : double.parse(_amountController.text),
        amount: double.parse(_amountController.text),
        goods: _targetgoodsController.text,
        category: _categoryController.text,
        categoryType: currentCategory,
        installation: installmentMonths,
        description: yearlyExpenseCategory.contains(_categoryController.text) &&  !_memoController.text.contains("#연간예산")? '#연간예산 ${_memoController.text}' : _memoController.text,
        extraBudget: yearlyExpenseCategory.contains(_categoryController.text) ? true : false,
        credit: iscredit
      ); 
      await DatabaseAdmin().insertMoneyTransaction(transaction);
  }

  Future<void> updateDataToDatabase() async {
    String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (_amountController.text.startsWith('-')) {
      amountText = '-${amountText.substring(1).replaceAll('-', '')}';
    } else {
      amountText = amountText.replaceAll('-', '');
    }
    _amountController.text = amountText;
    MoneyTransaction transaction = MoneyTransaction(
      id: int.parse(_idController.text),
      transactionTime: '${_dateController.text}T${_timeController.text}', // 여기서는 현재 시간을 사용할 수 있습니다. 
      // account: _accountController.text,
      amount: double.parse(_amountController.text),
      goods: _targetgoodsController.text,
      category: _categoryController.text,
      categoryType: currentCategory,
      installation: int.tryParse(_installmentController.text) ?? 1,
      description: yearlyExpenseCategory.contains(_categoryController.text) &&  !_memoController.text.contains("#연간예산 ")? '#연간예산 ${_memoController.text}' : _memoController.text,
      extraBudget: yearlyExpenseCategory.contains(_categoryController.text) ? true : false,
      credit: iscredit
    );

    await DatabaseAdmin().updateMoneyTransaction(transaction);
  }

}

// 금액 형식으로 입력된 값을 변환하여 반환합니다.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  Logger logger = Logger();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {

    String oldText = oldValue.text.replaceAll(RegExp(r'[^0-9.-]'), '');
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.-]'), '');

    if(oldText.contains('-'))
    {
      newText = '-${newText.replaceAll(RegExp(r'-'), '')}';
    }
    // logger.i('numberText${newValue.text}');
    logger.i('newText$newText');
    String formattedText = '';
    final double? value = double.tryParse(newText);
    if (value == null) {
      return newValue.copyWith(
        text: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(0),
        selection: TextSelection.collapsed(
          offset: formattedText.length.clamp(0, formattedText.length),
        ),
      ); // 변환 실패 시 기존 값 유지
    }
    // final double value = double.parse(newText);
    // formattedText = NumberFormat.simpleCurrency(decimalDigits: 2, locale: "ko-KR").format(value);
    // if(oldText.contains('.') && value% 1 == 0) {
    if(newText.contains('.')) {
      formattedText = NumberFormat.simpleCurrency(decimalDigits: 2, locale: "ko-KR").format(value);
    } else {
      formattedText = NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(value);
    }
    // 기존 텍스트 길이 및 커서 위치
    final int oldTextLength = oldValue.text.length;
    final int cursorPosition = oldValue.selection.base.offset;

    // 길이 차이에 따른 커서 위치 보정
    final int offsetAdjustment = oldTextLength - cursorPosition;
    final int newCursorPosition = formattedText.length - offsetAdjustment;

    // 커서 위치를 범위 내로 제한
    final int clampedCursorPosition = newCursorPosition.clamp(0, formattedText.length);
    if (newText.contains('.') && !oldValue.text.contains('.')){
      logger.d('dot put');
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length-1),
      );
    } else {
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: clampedCursorPosition),
      );
    }
  }
}