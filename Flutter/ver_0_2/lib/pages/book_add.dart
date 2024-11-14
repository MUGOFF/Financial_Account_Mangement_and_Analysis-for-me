import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  final FocusNode _focusAmountNode = FocusNode();
  UnfocusDisposition disposition = UnfocusDisposition.scope;
  PersistentBottomSheetController? _bottomSheetController;
  final GlobalKey<FormState> _formBookAddKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldBookAddKey = GlobalKey<ScaffoldState>();
  final TextEditingController _idController = TextEditingController();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  // final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountdisplayController = TextEditingController();
  final TextEditingController _installmentController = TextEditingController();
  final TextEditingController _targetgoodsController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String currentCategory = "소비";
  bool timeShow = false;
  bool installmentShow = false;
  late String _pageType;
  int _selectedButton = 1;
  bool _isMemoEditing = true;
  TextStyle normalStyle = const TextStyle(color: Colors.black, fontSize: 20);
  TextStyle tagStyle = TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20, backgroundColor: Colors.yellow.shade100);

  @override
  void initState() {
    super.initState();
    if(widget.moneyTransaction != null) {
      _pageType = "수정";
    } else {
      _pageType = "입력";
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
    _initializeControllers(); 
  }

  @override
  void dispose() {
    _focusAmountNode.dispose();
    super.dispose();
  }


  Future<void> _initializeControllers() async {
  // 페이지가 초기화될 때 받아온 정보를 사용하여 상태를 업데이트합니다.
    if (widget.moneyTransaction != null) {
      _idController.text = widget.moneyTransaction!.id.toString();
      List<String> parts = widget.moneyTransaction!.transactionTime.split('T');
      _dateController = TextEditingController(text: parts[0].trim());
      _timeController = TextEditingController(text: parts[1].trim());
      // _accountController.text = widget.moneyTransaction!.account.toString();
      _amountController.text = widget.moneyTransaction!.amount.toString();
      _amountdisplayController.text = _thousandsFormmater(_amountController.text);
      _targetgoodsController.text = widget.moneyTransaction!.goods;
      _categoryController.text = widget.moneyTransaction!.category;
      _memoController.text = widget.moneyTransaction!.description ?? '';
    } else {
      _dateController = TextEditingController(text: DateFormat('yyyy년 MM월 dd일').format(DateTime.now()));
      _timeController = TextEditingController(text:'${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}');
      _amountController.text = "-0";
      _amountdisplayController.text = _thousandsFormmater(_amountController.text);
    }
  }

  String _thousandsFormmater(String numberText) {
    final String newValueMinus = numberText.contains('-') ? '-' : '';
    final newText = numberText.replaceAll('-', '').replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
    final formattedText = '$newValueMinus  ₩  $newText';

    return formattedText;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        _focusAmountNode.unfocus(disposition: disposition);
        _bottomSheetController?.close();
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
                      1, '소비', Colors.red,
                      () {
                        setState(() {
                          _selectedButton = 1;
                          currentCategory = "소비";
                          _amountController.text = "-0";
                          _amountdisplayController.text = _thousandsFormmater(_amountController.text);
                        });
                      }
                    ),
                    categoryRadioButton(
                      2, '수입', Colors.blue,
                      () {
                        setState(() {
                          _selectedButton = 2;
                          currentCategory = "수입";
                          _amountController.text = "0";
                          _amountdisplayController.text = _thousandsFormmater(_amountController.text);
                        });
                      }
                    ),
                    categoryRadioButton(
                      3, '이체', Colors.grey,
                      () {
                        setState(() {
                          _selectedButton = 3;
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
                if(installmentShow)
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
                        children: [
                          AutoSizeText("메모", maxLines: 1),
                        ],
                      ),
                    ),
                    if(_isMemoEditing)
                    Expanded(
                      flex: 3,
                      child: 
                      TextFormField(
                        controller: _memoController,
                        autofocus: true,
                        onEditingComplete: () {
                          setState(() {
                            _isMemoEditing = false;
                          });
                        },
                      )
                    ),
                    if(!_isMemoEditing)
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black))
                        ),
                        child: buildRichText(_memoController),
                      ),
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
                      onPressed: () {
                        if (_formBookAddKey.currentState?.validate() ?? false) {
                          // Save data when Save button is pressed
                          _bottomSheetController?.close();
                          updateDataToDatabase();
                          Navigator.pop(context);
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
                      onPressed: () {
                        if (_formBookAddKey.currentState?.validate() ?? false) {
                          // Save data when Save button is pressed
                          _bottomSheetController?.close();
                          insertDataToDatabase();
                          Navigator.pop(context);
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
                                if( _pageType == "수정") {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('삭제 확인'),
                                        content: const Text('같은 대상을 일괄 변경하시겠습니까?'),
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
                                              DatabaseAdmin().updateCategorySearchAllTable(_targetgoodsController.text,item,currentCategory, double.parse(_amountController.text) > 0);
                                            },
                                            child: const Text('확인'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } 
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
                    return BorderSide(color: Colors.green.withOpacity(0.9));
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

  Widget buildRichText(TextEditingController controller) {
    final RegExp tagPattern = RegExp(r'#[ㄱ-ㅎ가-힣0-9a-zA-Z_]+ ');
    final String inputText = controller.text;
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    tagPattern.allMatches(inputText).forEach((match) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: inputText.substring(lastMatchEnd, match.start),
          style: normalStyle,
        ));
      }
      spans.add(TextSpan(
        text: inputText.substring(match.start, match.end),
        style: tagStyle, 
      ));
      lastMatchEnd = match.end;
    });
    if (lastMatchEnd < inputText.length) {
      spans.add(TextSpan(
        text: inputText.substring(lastMatchEnd),
        style: normalStyle,
      ));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMemoEditing = true;
        });
      },
      child: RichText(text: TextSpan(children: spans)),
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
            flex: _pageType == "입력"?  2: 3,
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
            ),
          ),
          if(_pageType == "입력")
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: installmentShow,
                  onChanged: (bool? value) {
                    setState(() {
                      installmentShow = value!;
                    });
                  },
                ),
                const Text('할부 여부')
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
                Expanded(
                  child: DatePicker(
                    controller: dateController,
                    tryValidator: true,
                  ),
                ),
                if(timeShow)
                Expanded(
                  child: TimePicker(
                    controller: timeController,
                    tryValidator: true,
                  ),
                ),
                if(!timeShow)
                Expanded(
                  child: 
                    Row(
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

  Widget categoryRadioButton(int value, String text, Color color, void Function() onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all<Size>(const Size(120, 30)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (_selectedButton == value) {
              return color.withOpacity(0.4);
            }
            return Colors.transparent;
          },
        ),
        side : WidgetStateProperty.resolveWith<BorderSide>(
          (Set<WidgetState> states) {
            if (_selectedButton == value) {
              return const BorderSide(color: Colors.transparent);
            }
            return BorderSide(color: color.withOpacity(0.9));
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

  void insertDataToDatabase() {
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

    if (installmentShow) {
      int installmentMonths = int.tryParse(_installmentController.text) ?? 1; // 할부 개월 수 가져오기
      DateTime startDate = DateFormat('yyyy년 MM월 dd일').parse(_dateController.text); // 시작 날짜
      for (int i = 0; i < installmentMonths; i++) {
        // 해당 달의 날짜 계산
        DateTime installmentDate = DateTime(startDate.year, startDate.month + i, startDate.day);
        String transactionTime = '${DateFormat('yyyy년 MM월 dd일').format(installmentDate).toString()}T${_timeController.text}';
        
        // 할부에 맞는 transaction 생성
        final MoneyTransaction transaction = MoneyTransaction(
          transactionTime: transactionTime,
          amount: double.parse((double.parse(_amountController.text) / installmentMonths).toStringAsFixed(2)), // 할부로 나눈 금액
          goods: '${_targetgoodsController.text}_${i+1}차분',
          category: _categoryController.text,
          categoryType: currentCategory,
          description: _categoryController.text == "특별 예산" && !_memoController.text.contains("#특별예산")
              ? '#특별예산 #${i+1}개월차 ${_memoController.text}'
              : '#${i+1}개월차 ${_memoController.text}',
          extraBudget: _categoryController.text == "특별 예산" ? true : false,
        );

        // 데이터베이스에 삽입
        DatabaseAdmin().insertMoneyTransaction(transaction);
      }
    } else {
      final MoneyTransaction transaction = MoneyTransaction(
        transactionTime: '${_dateController.text}T${_timeController.text}', // 여기서는 현재 시간을 사용할 수 있습니다. 
        // account: _accountController.text,
        // amount: currentCategory == "소비"? double.parse(_amountController.text).abs()*-1 : currentCategory == "수입"? double.parse(_amountController.text).abs() : double.parse(_amountController.text),
        amount: double.parse(_amountController.text),
        goods: _targetgoodsController.text,
        category: _categoryController.text,
        categoryType: currentCategory,
        description: _categoryController.text=="특별 예산" &&  !_memoController.text.contains("#특별예산")? '#특별예산 ${_memoController.text}' : _memoController.text,
        extraBudget: _categoryController.text=="특별 예산" ? true : false,
      );

      // 이제 transaction 객체를 데이터베이스에 삽입합니다.
      // 예시:
      DatabaseAdmin().insertMoneyTransaction(transaction);
    }
  }

  void updateDataToDatabase() {
    String amountText  = _amountdisplayController.text.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (_amountController.text.startsWith('-')) {
      amountText = '-${amountText.substring(1).replaceAll('-', '')}';
    } else {
      amountText = amountText.replaceAll('-', '');
    }
    _amountController.text = amountText;
    // 은행 계좌 정보 생성
    MoneyTransaction transaction = MoneyTransaction(
      id: int.parse(_idController.text),
      transactionTime: '${_dateController.text}T${_timeController.text}', // 여기서는 현재 시간을 사용할 수 있습니다. 
      // account: _accountController.text,
      amount: double.parse(_amountController.text),
      goods: _targetgoodsController.text,
      category: _categoryController.text,
      categoryType: currentCategory,
      description:_categoryController.text=="특별 예산" &&  !_memoController.text.contains("#특별예산 ")? '#특별예산 ${_memoController.text}' : _memoController.text,
      extraBudget: _categoryController.text=="특별 예산" ? true : false,
    );
    // 데이터베이스에 은행 계좌 정보 장장
    DatabaseAdmin().updateMoneyTransaction(transaction);
  }

}

// 금액 형식으로 입력된 값을 변환하여 반환합니다.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // 입력된 값을 금액 형식으로 변환합니다.
    final String newValueMinus = newValue.text.contains('-') ? '-' : '';
    final newText = newValue.text.replaceAll('-', '').replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    final formattedText = '$newValueMinus  ₩  $newText';
    final selectionIndex = formattedText.length;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

