import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:ver_0/widgets/database_admin.dart';
import 'package:ver_0/widgets/models/bank_account.dart';
import 'package:ver_0/widgets/models/card_account.dart';
import 'package:ver_0/widgets/models/money_transaction.dart';
import 'package:ver_0/widgets/models/expiration_investment.dart';
import 'package:ver_0/widgets/models/nonexpiration_investment.dart';

class ExternalTerminal extends StatelessWidget {
  const ExternalTerminal({super.key});

  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 탭의 수를 지정합니다. 여기서는 두 개의 탭이 있으므로 2로 설정합니다.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('외부 데이터 관리'),
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        ),
        body: const Column(
          children: [
            TabBar(
              tabs: <Widget>[
                Tab(text: '데이터 가져오기'),
                Tab(text: '데이터 내보내기'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  Center(child: TableDataIn()),
                  Center(child: TableDataOut()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableDataIn extends StatelessWidget {
  const TableDataIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.drive_folder_upload_rounded,
          size: 100.0,
        ),
        const SizedBox(height: 50),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.3,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        mainAxisSize:  MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const DialogContent(),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ) 
                    )
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // 원하는 모양으로 조절
              ),
            ),
            child: const Text('파일 업로드', style: TextStyle(fontSize: 36)),
          ),
        ),
      ],
    );
  }
}

class DialogContent extends StatefulWidget {
  const DialogContent({super.key});

  @override
 State<DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  FilePickerResult? filePicked;
  String? typeofDatas;
  List<dynamic> modelColumnrelations = [];
  List<dynamic> setData = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(_currentPageIndex > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (_currentPageIndex > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            if(_currentPageIndex == 0)
            const SizedBox(height: 48)
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height:_currentPageIndex > 1 ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.4,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: [
              FirstPage(
                onButtonPressed: (buttonValue) {
                  setState(() {
                    typeofDatas = buttonValue;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              ),
              SecondPage(
                onFilePathSelected: (path) {
                  setState(() {
                    filePicked = path;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              ThirdPage(
                onButtonPressed: (realtion, setforaccount) {
                  setState(() {
                    modelColumnrelations = realtion;
                    setData = setforaccount;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }, 
                filePicked: filePicked,
                typeofDatas: typeofDatas,
              ),
              ForthPage(
                onButtonPressed: () {
                  Navigator.of(context).pop();
                },
                filePicked: filePicked,
                typeofDatas: typeofDatas,
                modelColumnrelations: modelColumnrelations,
                setData: setData,
              ),
            ],
          ),
        ),
      ]
    );
  }
}

class FirstPage extends StatelessWidget {
  final Function(String?) onButtonPressed;

  const FirstPage({required this.onButtonPressed, super.key});

  Future<void> _onButtonPressed(String? value) async {
    final Logger logger = Logger();
    try {
      if (value != null) {
        onButtonPressed(value);
      } else {
        logger.w('No value selected.');
      }
    } catch (e) {
      logger.e('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('입력 정보 선택', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.3,
          child:ElevatedButton(
            onPressed: () {
              _onButtonPressed('book');
            },
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: const Text('가계부', style: TextStyle(fontSize: 24)),
          )
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.3,
          child:ElevatedButton(
            onPressed: null,
            // () {
            //   _onButtonPressed('invest');
            // },
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: const Text('투자', style: TextStyle(fontSize: 24)),
          )
        ),
      ],
    );
  }
}

class SecondPage extends StatelessWidget {
  final Function(FilePickerResult?) onFilePathSelected;

  const SecondPage({required this.onFilePathSelected, super.key});

  Future<void> _pickFile() async {
    final Logger logger = Logger();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withData: true,
      );
      if (result != null) {
        onFilePathSelected(result);
      } else {
        // 사용자가 파일을 선택하지 않았을 때 처리할 로직을 구현합니다.
        logger.w('No file selected.');
      }
    } catch (e) {
      logger.e('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text('파일 입력', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.3,
          child:ElevatedButton(
            onPressed: () {
              _pickFile();
            },
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: const Text('.csv(UTF-8)'),
          ),
        ),
        
      ],
    );
  }
}

class ThirdPage extends StatefulWidget {
  final FilePickerResult? filePicked;
  final String? typeofDatas;
  final Function(List<dynamic>, List<dynamic>) onButtonPressed;
  const ThirdPage({required this.filePicked, required this.onButtonPressed, required this.typeofDatas, super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final Logger logger = Logger();
  List<String> columnNames = [];
  List<dynamic> relationColumnandValue =List.filled(6, null);
  List<dynamic> relationColumnandselectedAccount = [];
  List<List<dynamic>> dataRows = [];
  String? selectedTransactionTime;
  String? selectedAccount;
  String? selectedAmount;
  String? selectedGoods;
  String? selectedCategory;
  String? selectedDescription;


  @override
  void initState() {
    super.initState();
    if (widget.filePicked != null) {
      _readColumnNames(widget.filePicked!);
    }
  }

  Future<void> _readColumnNames(FilePickerResult filePicked) async {
    try {
      if (filePicked.files.isNotEmpty) {
        String? fileName = filePicked.files.single.path;
        var input = File(fileName!).openRead();
        var fields = await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList();
        if (fields.isNotEmpty) {
          columnNames = fields.first.map((field) => field.toString()).toList();
          dataRows = fields.skip(1).toList();    
          setState(() {
            selectedTransactionTime = findMatchingColumn('transactionTime', '날짜', 0);
            selectedAmount = findMatchingColumn('amount', '금액', 1);
            selectedAccount = findMatchingColumn('account', '계좌', 2);
            selectedGoods = findMatchingColumn('goods', '상품', 3);
            selectedCategory = findMatchingColumn('category', '카테고리', 4);
            selectedDescription = findMatchingColumn('memo', '비고', 5);
          }); 
        }
      }
    } catch (e) {
      logger.e('Error while processing the file: $e');
    }
  }

  String? findMatchingColumn(String parameter, String koreanparameter ,int position) {
    for (var columnName in columnNames) {
      if (columnName.toLowerCase() == parameter.toLowerCase() || columnName.contains(koreanparameter)) {
        relationColumnandValue[position] = columnName;
        return columnName;
      }
    }
    return null;
  }

  bool isButtonEnabled() {
    return selectedTransactionTime != null &&
           selectedAmount != null &&
           selectedAccount != null &&
           selectedGoods != null;
  }

  Future<void> _onButtonPressed(List<dynamic> realtion, List<dynamic> setforaccount) async {
    final Logger logger = Logger();
    try {
      widget.onButtonPressed(realtion, setforaccount);
    } catch (e) {
      logger.e('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text('칼럼 정렬', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        if (widget.filePicked != null)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTextDropdown('거래 시간', true, selectedTransactionTime, (newValue) {
              setState(() {
                selectedTransactionTime = newValue;
                relationColumnandValue[0] = newValue;
              });
            }),
            buildTextDropdown('거래 금액', true, selectedAmount, (newValue) {
              setState(() {
                selectedAmount = newValue;
                relationColumnandValue[1] = newValue;
              });
            }),
            buildTextDropdown('거래 계좌', true, selectedAccount, (newValue) {
              setState(() {
                selectedAccount = newValue;
                relationColumnandValue[2] = newValue;
              });
            }),
            buildTextDropdown('거래 상품', true, selectedGoods, (newValue) {
              setState(() {
                selectedGoods = newValue;
                relationColumnandValue[3] = newValue;
              });
            }),
            buildTextDropdown('비용 종류', false, selectedCategory, (newValue) {
              setState(() {
                selectedCategory = newValue;
                relationColumnandValue[4] = newValue;
              });
            }),
            buildTextDropdown('메모', false, selectedDescription, (newValue) {
              setState(() {
                selectedDescription = newValue;
                relationColumnandValue[5] = newValue;
              });
            }),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.2,
          child:ElevatedButton(
            onPressed: isButtonEnabled() ? () {
              List<dynamic> accountColumnData = [];
              int dataColumnIndex = columnNames.indexOf(selectedAccount!);
              for (List<dynamic> row in dataRows) {
                accountColumnData.add(row[dataColumnIndex]);
              }
              relationColumnandselectedAccount = accountColumnData.toSet().toList();
              _onButtonPressed(relationColumnandValue,relationColumnandselectedAccount);
            } : null,
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: const Text('다음 단계'),
          ),
        ),
      ],
    );
  }
  
  Widget buildTextDropdown(String title,bool  requiredParameter, String? parameter, Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 20)),
            if (requiredParameter)
            const Text('*', style: TextStyle(color: Colors.red))
          ]
        ),
        DropdownButton<String>(
          value: parameter,
          items: columnNames.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ForthPage extends StatefulWidget {
  final VoidCallback onButtonPressed;
  final FilePickerResult? filePicked;
  final String? typeofDatas;
  final List<dynamic> modelColumnrelations;
  final List<dynamic> setData;

  const ForthPage({required this.filePicked, required this.onButtonPressed, required this.typeofDatas, required this.modelColumnrelations, required this.setData, super.key});

  @override
  State<ForthPage> createState() => _ForthPageState();
}

class _ForthPageState extends State<ForthPage> {
  final Logger logger = Logger();
  String? dateFormat;
  final List<String> dateFormats = ['yyyy-MM-dd', 'MM/dd/yyyy', 'dd/MM/yyyy', 'yyyy년 MM월 dd일'];
  final List<String> timeFormats = ['hh:mm:ss', 'hh시 mm분 ss초'];
  final List<String> datetimeFormats = [];
  List<String> columnNames = [];
  List<List<dynamic>> dataRows = [];
  List<dynamic>? relationColumnandValue;
  List<String> accountNames = [];


  @override
  void initState() {
    super.initState();
    relationColumnandValue = List.filled(widget.setData.length, null);
    if (widget.filePicked != null) {
      _readColumnNames(widget.filePicked!);
    }
    _readAccountsinDatabase();
  }

  Future<void> _readColumnNames(FilePickerResult filePicked) async {
    try {
      if (filePicked.files.isNotEmpty) {
        String? fileName = filePicked.files.single.path;
        var input = File(fileName!).openRead();
        var fields = await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList();
        if (fields.isNotEmpty) {
          columnNames = fields.first.map((field) => field.toString()).toList();
          dataRows = fields.skip(1).toList();
          // logger.d(dataRows);
        }
      }
    } catch (e) {
      logger.e('Error while processing the file: $e');
    }
  }

  Future<void> _readAccountsinDatabase() async{
    List<BankAccount> fetchedBankAccounts = await DatabaseAdmin().getAllBankAccounts();
    List<CardAccount> fetchedCardAccounts = await DatabaseAdmin().getAllCardAccounts();
    await Future.forEach(fetchedBankAccounts, (bankAccount) async {
      accountNames.add(bankAccount.bankName);
    });
    await Future.forEach(fetchedCardAccounts, (cardAccount) async {
      accountNames.add(cardAccount.cardName);
    });
  }

  bool isButtonEnabled(List<dynamic>? relationColumnandValue) {
    return relationColumnandValue != null && !relationColumnandValue.contains(null);
  }

  @override
  Widget build(BuildContext context) {
    if (datetimeFormats.isEmpty) {
      for (String dateFormat in dateFormats) {
        for (String timeFormat in timeFormats) {
          datetimeFormats.add('$dateFormat $timeFormat');
        }
      }
      // 초기 선택값 설정
      if (datetimeFormats.isNotEmpty) {
        dateFormat = datetimeFormats[0];
      }
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('추가 선택', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (widget.filePicked != null)
          Expanded(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('날짜시간 포맷', style: TextStyle(fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: dateFormat,
                      items: datetimeFormats.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          dateFormat = newValue;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('계좌 선택', style: TextStyle(fontSize: 20)),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.setData.length,
                  itemBuilder: (context, index) {
                    return buildTextDropdown(widget.setData[index].toString(), relationColumnandValue![index], (newValue) {
                        setState(() {
                          try {
                            relationColumnandValue![index] = newValue;
                          } catch (e) {
                            logger.e("error: $e");
                          }
                        });
                      });
                    // return Text(widget.setData[index].toString());
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4*0.2,
            child:ElevatedButton(
              onPressed: isButtonEnabled(relationColumnandValue) ? () {
                insertDatasToDatabase(dataRows);
                widget.onButtonPressed();
              } : null,
              style: ElevatedButton.styleFrom(
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
              child: const Text('선택 완료'),
            ),
          ),
        ],
    );
  }

  Widget buildTextDropdown(String title, dynamic parameter, Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 20)),
          ]
        ),
        DropdownButton<String>(
          value: parameter,
          items: accountNames.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void insertDatasToDatabase(List<List<dynamic>> dataRows) {
    for (var row in dataRows) {
      String formattedDatetime = DateFormat('yyyy년 MM월 dd일THH:mm:ss').format(DateFormat(dateFormat).parse(row[columnNames.indexOf(widget.modelColumnrelations[0])]));
      try {
          MoneyTransaction transaction = MoneyTransaction(
            transactionTime: formattedDatetime,
            amount: double.parse(row[columnNames.indexOf(widget.modelColumnrelations[1])].toString()),
            account: accountNames[widget.setData.indexOf(row[columnNames.indexOf(widget.modelColumnrelations[2])])],
            goods: row[columnNames.indexOf(widget.modelColumnrelations[3])],
            category: widget.modelColumnrelations[4] != null ? row[columnNames.indexOf(widget.modelColumnrelations[4])] : "",
            description: widget.modelColumnrelations[5] != null ? row[columnNames.indexOf(widget.modelColumnrelations[5])] : "",
          );
          try {
            DatabaseAdmin().insertMoneyTransaction(transaction);
          } catch (e) {
            logger.e('error: $e, not enough row data: $row');
          }
      } catch(e) {
        logger.e('error: $e, formData row: $row');
      }
    }
  }
}

class TableDataOut extends StatefulWidget {
  const TableDataOut({super.key});

  @override
  State<TableDataOut> createState() => _TableDataOutState();
}

class _TableDataOutState extends State<TableDataOut> {
  @override
  Widget build(BuildContext context) {
    return const Text("업데이트 예정");
  }
}