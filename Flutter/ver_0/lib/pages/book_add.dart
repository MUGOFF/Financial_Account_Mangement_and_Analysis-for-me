import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:ver_0/widgets/date_picker.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/money_transaction.dart';
import 'package:ver_0/widgets/models/bank_account.dart';
import 'package:ver_0/widgets/models/card_account.dart';
import 'package:ver_0/widgets/models/transaction_category.dart';

class BookAdd extends StatefulWidget {
  final MoneyTransaction? moneyTransaction;
  const BookAdd({this.moneyTransaction, super.key});

  @override
  State<BookAdd> createState() => _BookAddState();
}

class _BookAddState extends State<BookAdd> {
  Logger logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountdisplayController = TextEditingController();
  final TextEditingController _targetgoodsController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  String currentCategory = "소비";
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
    _initializeControllers(); 
  }


  Future<void> _initializeControllers() async {
  // 페이지가 초기화될 때 받아온 정보를 사용하여 상태를 업데이트합니다.
    if (widget.moneyTransaction != null) {
      _idController.text = widget.moneyTransaction!.id.toString();
      List<String> parts = widget.moneyTransaction!.transactionTime.split('T');
      _dateController = TextEditingController(text: parts[0].trim());
      _timeController = TextEditingController(text: parts[1].trim());
      _accountController.text = widget.moneyTransaction!.account.toString();
      _amountdisplayController.text = _thousandsFormmater(widget.moneyTransaction!.amount.toString());
      _amountController.text = widget.moneyTransaction!.amount.toString();
      _targetgoodsController.text = widget.moneyTransaction!.goods;
      _categoryController.text = widget.moneyTransaction!.category;
      _memoController.text = widget.moneyTransaction!.description ?? '';
    } else {
      _dateController = TextEditingController(text: DateFormat('yyyy년 MM월 dd일').format(DateTime.now()));
      _timeController = TextEditingController(text:'${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('가계부 $_pageType'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildRadioButton(1, '소비', Colors.red),
                  buildRadioButton(2, '수입', Colors.green),
                  buildRadioButton(3, '이체', Colors.grey),
                ],
              ),
              const SizedBox(height: 16.0), // Add spacing between rows and buttons
              // Date, String, Int, String, String Fields
              buildDateTimeRow("날짜", _dateController, _timeController),
              buildNumericRow("거래금액", _amountdisplayController),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("거래계좌"),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      readOnly: true,
                      controller: _accountController,
                      onTap: () {
                        _showAccountModal(context);
                      },
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
              buildTextRow("거래대상", _targetgoodsController),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("거래분류"),
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
                        Text("메모"),
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
                  ElevatedButton(
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
                                  Navigator.pop(context);
                                  deleteDataFromDatabase(); // Delete data
                                  Navigator.pop(context);
                                },
                                child: const Text('삭제'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text('취소'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('삭제'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Save data when Save button is pressed
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
                      Navigator.pop(context);
                    },
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        // Save data when Save button is pressed
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
    );
  }
  void _showAccountModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<dynamic>>(
          future: Future.wait([
            DatabaseAdmin().getAllBankAccounts(),
            DatabaseAdmin().getAllCardAccounts(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // 데이터 로딩 중이면 로딩 인디케이터 표시
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            List<BankAccount> fetchedBankAccounts = snapshot.data?[0] ?? [];
            List<CardAccount> fetchedCardAccounts = snapshot.data?[1] ?? [];
            if (fetchedBankAccounts.isEmpty && fetchedCardAccounts.isEmpty) {
              return const Text('No data available'); // 데이터가 없을 경우
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (fetchedBankAccounts.isNotEmpty) ...[
                  const ListTile(
                    title: Text(
                      '은행 계좌',
                      style: TextStyle(fontWeight: FontWeight.bold,)
                    ),
                    dense: true,
                  ),
                  ...fetchedBankAccounts.map((bankAccount) {
                    return ListTile(
                      title: Text(bankAccount.bankName),
                      onTap: () {
                        setState(() {
                          _accountController.text = bankAccount.bankName.toString();
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
                if (fetchedCardAccounts.isNotEmpty) ...[
                  const ListTile(
                    title: Text(
                      '카드',
                      style: TextStyle(fontWeight: FontWeight.bold,)
                      ),
                    dense: true,
                  ),
                  ...fetchedCardAccounts.map((cardAccount) {
                    return ListTile(
                      title: Text(cardAccount.cardName),
                      onTap: () {
                        setState(() {
                          _accountController.text = cardAccount.cardName.toString();
                          // Handle the selection of card account
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ],
            );
          },
        );
      },
    );
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

  Widget buildNumericRow(String label, TextEditingController controller) {
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
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Field is required';
                }
                return null;
              },
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Increased font size
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
            ),
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
                Expanded(
                  child: TimePicker(
                    controller: timeController,
                    tryValidator: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRadioButton(int value, String text, Color color) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedButton = value;
          currentCategory = text;
        });
      },
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(const Size(120, 30)),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (_selectedButton == value) {
              return color.withOpacity(0.4);
            }
            return Colors.transparent;
          },
        ),
        side : MaterialStateProperty.resolveWith<BorderSide>(
          (Set<MaterialState> states) {
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
    final MoneyTransaction transaction = MoneyTransaction(
      transactionTime: '${_dateController.text}T${_timeController.text}', // 여기서는 현재 시간을 사용할 수 있습니다. 
      account: _accountController.text,
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
      account: _accountController.text,
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

  void deleteDataFromDatabase() {
    DatabaseAdmin().deleteMoneyTransaction(int.parse(_idController.text));
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

