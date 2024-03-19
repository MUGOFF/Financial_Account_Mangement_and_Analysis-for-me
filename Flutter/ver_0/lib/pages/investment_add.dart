import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:ver_0/widgets/date_picker.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/expiration_investment.dart';
import 'package:ver_0/widgets/models/nonexpiration_investment.dart';
import 'package:intl/intl.dart';


class InvestAdd extends StatefulWidget {
  final ExpirationInvestment? expirationInvestment;
  final NonexpirationInvestment? nonExpirationInvestment;
  const InvestAdd({this.expirationInvestment, this.nonExpirationInvestment, super.key});

  @override
  State<InvestAdd> createState() => _InvestAddState();
}

class _InvestAddState extends State<InvestAdd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  bool expiralable = false;
  late final TextEditingController _startDateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endDateController;
  late final TextEditingController _endTimeController;
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountDisplayController = TextEditingController();
  final TextEditingController _valuePriceController = TextEditingController();
  final TextEditingController _valuePriceDisplayController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _costDisplayController = TextEditingController();
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _investcategoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String currentCategory = "매수";
  late String _pageType;
  int _selectedButton = 1; // Initially, the first button is selected

  @override
  void initState() {
    super.initState();
    if(widget.expirationInvestment != null || widget.nonExpirationInvestment != null) {
      _pageType = "수정";
    } else {
      _pageType = "입력";
    }
    _initializeControllers(); 
  }

  Future<void> _initializeControllers() async {
  // 페이지가 초기화될 때 받아온 정보를 사용하여 상태를 업데이트합니다.
    if (widget.expirationInvestment != null) {
      _typeController.text = '만기형';
      _idController.text = widget.expirationInvestment!.id.toString();
      List<String> parts = widget.expirationInvestment!.investTime.split('T');
      _startDateController = TextEditingController(text: parts[0].trim());
      _startTimeController = TextEditingController(text: parts[1].trim());
      List<String> parts2 = widget.expirationInvestment!.expirationTime.split('T');
      _endDateController = TextEditingController(text: parts2[0].trim());
      _endTimeController = TextEditingController(text: parts2[1].trim());
      _interestRateController.text = widget.expirationInvestment!.interestRate.toString();
      _accountController.text = widget.expirationInvestment!.account;
      _amountController.text = widget.expirationInvestment!.amount.toString();
      _costController.text = widget.expirationInvestment!.cost.toString();
      _valuePriceController.text = widget.expirationInvestment!.valuePrice.toString();
      _investmentController.text = widget.expirationInvestment!.investment;
      _investcategoryController.text = widget.expirationInvestment!.investcategory;
      _currencyController.text = widget.expirationInvestment!.currency;
      _descriptionController.text = widget.expirationInvestment!.description ?? '';
    } else if (widget.nonExpirationInvestment != null) {
      _typeController.text = '비만기형';
      _idController.text = widget.nonExpirationInvestment!.id.toString();
      List<String> parts = widget.nonExpirationInvestment!.investTime.split('T');
      _startDateController = TextEditingController(text: parts[0].trim());
      _startTimeController = TextEditingController(text: parts[1].trim());
      _accountController.text = widget.nonExpirationInvestment!.account;
      _amountController.text = widget.nonExpirationInvestment!.amount.toString();
      _costController.text = widget.nonExpirationInvestment!.cost.toString();
      _valuePriceController.text = widget.nonExpirationInvestment!.valuePrice.toString();
      _investmentController.text = widget.nonExpirationInvestment!.investment;
      _investcategoryController.text = widget.nonExpirationInvestment!.investcategory;
      _currencyController.text = widget.nonExpirationInvestment!.currency;
      _descriptionController.text = widget.nonExpirationInvestment!.description ?? '';
    } else {
      _typeController.text = '비만기형';
      _currencyController.text = "KRW";
      _startDateController = TextEditingController(text: DateFormat('yyyy년 MM월 dd일').format(DateTime.now()));
      _startTimeController = TextEditingController(text:'${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}');
      _endDateController = TextEditingController(text: DateFormat('yyyy년 MM월 dd일').format(DateTime.now()));
      _endTimeController = TextEditingController(text:'${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투자 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildRadioButton(1, '매수', Colors.red),
                buildRadioButton(2, '매도', Colors.blue),
                buildRadioButton(3, '기타', Colors.grey),
              ],
            ),
            const SizedBox(height: 16.0),
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 만기 여부, 통화, 투자대상
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("만기 여부"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            readOnly: true,
                            controller: _typeController,
                            onTap: () {
                              _showModal(context, _typeController, ["만기형", "비만기형"]);
                            },
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("통화"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            readOnly: true,
                            controller: _currencyController,
                            onTap: () {
                              _showModal(context, _currencyController, ["KRW", "USD", "JPY", "기타"]);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("투자대상"),
                            ],
                          ),
                        ),
                        if(currentCategory == "매도")
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            readOnly: true,
                            controller: _investcategoryController,
                            onTap: () {
                              _showModal(context, _investcategoryController, ["주식", "채권", "파생", "저축만기"]);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if(currentCategory == "매수")
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            readOnly: true,
                            controller: _investcategoryController,
                            onTap: () {
                              _showModal(context, _investcategoryController, ["주식", "채권", "파생"]);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if(currentCategory == "기타")
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            readOnly: true,
                            controller: _investcategoryController,
                            onTap: () {
                              _showModal(context, _investcategoryController, ["환전", "저축", "배당금", "이자"]);
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
                    //  거래규모 , 단위가격 , 비용
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("거래규모"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            controller: _amountDisplayController,
                            keyboardType: TextInputType.number,
                            onTap: () {
                              _amountDisplayController.selection = TextSelection.collapsed(offset: _amountDisplayController.text.length);
                            },
                            decoration: InputDecoration(
                              suffixIcon: _amountDisplayController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.highlight_remove),
                                  onPressed: () {
                                    setState(() {
                                      _amountDisplayController.clear(); // 데이터를 모두 제거
                                    });
                                  },
                                ): null,
                            ),
                            inputFormatters: [ThousandsSeparatorInputFormatter()],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ]
                    ),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("단위가격"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            controller: _valuePriceDisplayController,
                            keyboardType: TextInputType.number,
                            onTap: () {
                              _valuePriceDisplayController.selection = TextSelection.collapsed(offset: _valuePriceDisplayController.text.indexOf("."));
                            },
                            decoration: InputDecoration(
                              suffixIcon: _valuePriceDisplayController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.highlight_remove),
                                  onPressed: () {
                                    setState(() {
                                      _valuePriceDisplayController.clear(); // 데이터를 모두 제거
                                    });
                                  },
                                ): null,
                            ),
                            inputFormatters: [CurrencyFormatter(_currencyController.text)],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Field is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ]
                    ),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("비용"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            cursorColor: Colors.transparent,
                            controller: _costDisplayController,
                            keyboardType: TextInputType.number,
                            onTap: () {
                              _costDisplayController.selection = TextSelection.collapsed(offset: _costDisplayController.text.indexOf("."));
                            },
                            decoration: InputDecoration(
                              suffixIcon: _costDisplayController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.highlight_remove),
                                  onPressed: () {
                                    setState(() {
                                      _costDisplayController.clear(); // 데이터를 모두 제거
                                    });
                                  },
                                ): null,
                            ),
                            inputFormatters: [CurrencyFormatter(_currencyController.text)],
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
                    // 투자 날짜
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("투자 날짜"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: DatePicker(
                                  controller: _startDateController,
                                  tryValidator: true,
                                ),
                              ),
                              Expanded(
                                child: TimePicker(
                                  controller: _startTimeController,
                                  tryValidator: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if(_typeController.text != "만기형")
                    unexpirationoptionalForm(),
                    if(_typeController.text == "만기형")
                    expirationoptionalForm(),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("투자 메모"),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            textAlign: TextAlign.left,
                            controller: _descriptionController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0), // Add spacing between buttons
                    if(_pageType == "수정")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //삭제버튼
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child:  ElevatedButton(
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
                                          deleteDataFromDatabase();
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
                          )
                        ),
                        //수정버튼
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Save data when Save button is pressed
                                updateDataToDatabase();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('수정'),
                          )
                        ),
                      ],
                    ),
                    if(_pageType == "입력")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //취소버튼
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle Cancel button press
                              Navigator.pop(context);
                            },
                            child: const Text('취소'),
                          ),
                        ),
                        //저장버튼
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Save data when Save button is pressed
                                insertDataToDatabase();
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('저장'),
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 비만기형 상품 폼
  Widget unexpirationoptionalForm() {
    return Column(
      children: [
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
              flex: 2,
              child: TextFormField(
                textAlign: TextAlign.center,
                cursorColor: Colors.transparent,
                readOnly: true,
                controller: _accountController,
                onTap: () {
                  _showModal(context, _accountController, ["/"]);
                },
              ),
            ),
            const Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("거래대상"),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: TextFormField(
                textAlign: TextAlign.center,
                cursorColor: Colors.transparent,
                controller: _investmentController,
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
      ],
    );
  }

  // 만기형 상품 폼
  Widget expirationoptionalForm() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("만기 날짜"),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            _endDateController.text = DateFormat('yyyy년 MM월 dd일').format(picked);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field       is';
                          }
                          if(
                            DateFormat('yyyy년 MM월 dd일THH:mm').parse('${value}T${_endTimeController.text}').isBefore(DateFormat('yyyy년 MM월 dd일THH:mm').parse('${_startDateController.text}T${_startTimeController.text}')) ||
                            DateFormat('yyyy년 MM월 dd일THH:mm').parse('${value}T${_endTimeController.text}').isAtSameMomentAs(DateFormat('yyyy년 MM월 dd일THH:mm').parse('${_startDateController.text}T${_startTimeController.text}'))
                            ) {
                            return '날짜와 시간이 시작시간과 ';
                          }
                          return null;
                        },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      readOnly: true,
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          _endTimeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}'; // 선택된 날짜를 텍스트 필드에 표시
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required';
                        }
                        if(DateFormat('yyyy년 MM월 dd일THH:mm').parse('${_endDateController.text}T$value').isBefore(DateFormat('yyyy년 MM월 dd일THH:mm').parse('${_startDateController.text}T${_startTimeController.text}'))  ) {
                          return '같거나 이전입니다';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        //  거래계좌 , 거래대상 , 이자율
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
              flex: 1,
              child: TextFormField(
                textAlign: TextAlign.center,
                cursorColor: Colors.transparent,
                controller: _accountController,
              ),
            ),
            const Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("거래대상"),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextFormField(
                textAlign: TextAlign.center,
                cursorColor: Colors.transparent,
                controller: _investmentController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
            const Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("이자율"),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextFormField(
                textAlign: TextAlign.center,
                cursorColor: Colors.transparent,
                controller: _interestRateController,
                keyboardType: TextInputType.number,
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
      ],
    );
  }


  Widget buildRow(String label, TextEditingController controller, TextInputType firsttype, {String? seclabel, TextEditingController? seccontroller, TextInputType? sectype}) {
    if(seclabel == null){
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
                keyboardType: firsttype,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Increased font size
                ),
              ),
            ),
          ],
        ),
      );
    } else {
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
              flex: 1,
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
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(seclabel),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TextFormField(
                controller: seccontroller,
                keyboardType: sectype,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Increased font size
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget buildRadioButton(int value, String text, Color color) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedButton = value;
          currentCategory = text;
          _investcategoryController.text = "";
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

  void _showModal(BuildContext context, TextEditingController controller, List<dynamic> itemsList) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3,),
        child: ListView.builder(
          itemCount: itemsList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(itemsList[index].toString()),
              onTap: () {
                setState(() {
                  controller.text = itemsList[index].toString();
                });
                Navigator.pop(context);
              },
            );
          },
        ),
      );
    },
  );
}

  void insertDataToDatabase() {
    _amountController.text = _amountDisplayController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    _valuePriceController.text = _valuePriceDisplayController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    _costController.text = _costDisplayController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (_typeController.text == '만기형') {
    // 만기형 계좌 정보 생성
    ExpirationInvestment newInvestment = ExpirationInvestment(
      investTime: '${_startDateController.text}T${_startTimeController.text}',
      expirationTime: '${_endDateController.text}T${_endTimeController.text}',
      interestRate: double.parse(_interestRateController.text),
      account: _accountController.text,
      amount: currentCategory == "매도"? double.parse(_amountController.text)*-1 : double.parse(_amountController.text),
      valuePrice: double.parse(_valuePriceController.text),
      cost: double.parse(_costController.text),
      investment: _investmentController.text,
      investcategory: _investcategoryController.text,
      currency: _currencyController.text,
      description: _descriptionController.text,
    );
    // 데이터베이스에 만기형 계좌 정보 삽입
    DatabaseAdmin().insertExpirationInvestment(newInvestment);
    } else if (_typeController.text == '비만기형') {
      // 비만기형 계좌 정보 생성
      NonexpirationInvestment newInvestment = NonexpirationInvestment(
        investTime: '${_startDateController.text}T${_startTimeController.text}',
        account: _accountController.text,
        amount: currentCategory == "매도"? double.parse(_amountController.text)*-1 : double.parse(_amountController.text),
        valuePrice: double.parse(_valuePriceController.text),
        cost: double.parse(_costController.text),
        investment: _investmentController.text,
        investcategory: _investcategoryController.text,
        currency: _currencyController.text,
        description: _descriptionController.text,
      );
      // 데이터베이스에 비만기형 계좌 정보 삽입
      DatabaseAdmin().insertNonExpirationInvestment(newInvestment);
    }
  }

  void updateDataToDatabase() {
    _amountController.text = _amountDisplayController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    _valuePriceController.text = _valuePriceDisplayController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    _costController.text = _costDisplayController.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (_typeController.text == '만기형') {
      // 만기형 계좌 정보 생성
      ExpirationInvestment newInvestment = ExpirationInvestment(
        id: int.parse(_idController.text),
        investTime: '${_startDateController.text}T${_startTimeController.text}',
        expirationTime: '${_endDateController.text}T${_endTimeController.text}',
        interestRate: double.parse(_interestRateController.text),
        account: _accountController.text,
        amount: currentCategory == "매도"? double.parse(_amountController.text)*-1 : double.parse(_amountController.text),
        valuePrice: double.parse(_valuePriceController.text),
        cost: double.parse(_costController.text),
        investment: _investmentController.text,
        investcategory: _investcategoryController.text,
        currency: _currencyController.text,
        description: _descriptionController.text,
      );
      // 데이터베이스에 만기형 계좌 정보 장장
      DatabaseAdmin().updateExpirationInvestment(newInvestment);
    } else if (_typeController.text == '비만기형') {
      // 비만기형 계좌 정보 생성
      NonexpirationInvestment newInvestment = NonexpirationInvestment(
        id: int.parse(_idController.text), // 이 부분은 적절한 정보로 수정해야 합니다.
        investTime: '${_startDateController.text}T${_startTimeController.text}',
        account: _accountController.text,
        amount: currentCategory == "매도"? double.parse(_amountController.text)*-1 : double.parse(_amountController.text),
        valuePrice: double.parse(_valuePriceController.text),
        cost: double.parse(_costController.text),
        investment: _investmentController.text,
        investcategory: _investcategoryController.text,
        currency: _currencyController.text,
        description: _descriptionController.text,
      );
      // 데이터베이스에 비만기형 계좌 정보 정정
      DatabaseAdmin().updateNonExpirationInvestment(newInvestment);
    }
  }

  void deleteDataFromDatabase() {
    if (_typeController.text == '만기형') {
    // 데이터베이스에 만기형 계좌 정보 삭제
      DatabaseAdmin().deleteExpirationInvestment(int.parse(_idController.text));
    } else if (_typeController.text == '비만기형') {
      // 데이터베이스에 비만기형 계좌 정보 삭제
      DatabaseAdmin().deleteNonExpirationInvestment(int.parse(_idController.text));
    }
  }
}

// 금액 형식으로 입력된 값을 변환하여 반환합니다.
class CurrencyFormatter extends TextInputFormatter {
  final String currency;
  late String currencySymbol;

  String getCurrencySymbol(String currency) {
    if (currency == 'KRW') {
      return '₩';
    } else if (currency == 'USD') {
      return '\$';
    } else if (currency == 'JPY') {
      return '¥';
    } else {
      return '';
    }
  }

  CurrencyFormatter(this.currency){
    currencySymbol = getCurrencySymbol(currency);
  }

 @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    int doubleDot = newValue.text.indexOf('..');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formattedText = _formatText(text, currencySymbol);

    int newCursorPosition = newValue.selection.baseOffset;
    if (doubleDot > 0 || newValue.selection.baseOffset > formattedText.indexOf('.')+1) {
      newCursorPosition = min(newValue.selection.baseOffset, formattedText.length);
    } else {
      newCursorPosition = formattedText.indexOf('.');
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  String _formatText(String text, String currencySymbol) {
    // Remove non-numeric characters
    String cleanedText = text.replaceAll(RegExp('[^0-9.]'), '').replaceAll(RegExp('\\.\\.'), '.');

    // Split integer and decimal parts
    List<String> parts = cleanedText.split('.');
    String integerPart = parts[0] != '' ? int.parse(parts[0]).toString() : '0';
    String decimalPart = parts.length > 1 ? parts[1].substring(0, min(parts[1].length, 2)).padRight(2, '0') : '00';

    // Add commas every 3 digits in integer part
    if (integerPart.length > 3) {
      integerPart = integerPart.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},');
    }

    return '$currencySymbol  $integerPart.$decimalPart';
  }
}

//기본 천단위 포맷터
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String cleanedText = newValue.text.replaceAll(RegExp('[^0-9.]'), '');
    
    final newText = cleanedText.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );

    final selectionIndex = newText.length;

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}


