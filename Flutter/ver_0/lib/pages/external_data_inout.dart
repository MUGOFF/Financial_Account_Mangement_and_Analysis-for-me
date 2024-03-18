import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:ver_0/widgets/database_admin.dart';
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
        ElevatedButton(
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
          child: const Text('파일 업로드'),
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
          height:_currentPageIndex == 2 ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.4,
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
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              ),
              SecondPage(
                onFilePathSelected: (path) {
                  setState(() {
                    filePicked = path; // 파일 경로 변수 업데이트
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
              ),
              ThirdPage(
                onButtonPressed: () {
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
                }
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
            onPressed: onButtonPressed('book'),
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
            onPressed: onButtonPressed('invest'),
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
  final VoidCallback onButtonPressed;
  const ThirdPage({required this.filePicked, required this.onButtonPressed, required this.typeofDatas, super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final Logger logger = Logger();
  List<String> columnNames = [];
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
          List<List<dynamic>> dataRows = fields.skip(1).toList();          
          setState(() {
            selectedTransactionTime = findMatchingColumn('transactionTime', '날짜');
            selectedAccount = findMatchingColumn('account', '계좌');
            selectedAmount = findMatchingColumn('amount', '금액');
            selectedGoods = findMatchingColumn('goods', '상품');
            selectedCategory = findMatchingColumn('category', '카테고리');
            selectedDescription = findMatchingColumn('memo', '비고');
          }); 
        }
      }
    } catch (e) {
      logger.e('Error while processing the file: $e');
    }
  }

  String? findMatchingColumn(String parameter, String koreanparameter) {
    for (var columnName in columnNames) {
      if (columnName.toLowerCase() == parameter.toLowerCase() || columnName.contains(koreanparameter)) {
        return columnName;
      }
    }
    return null;
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
              });
            }),
            buildTextDropdown('거래 금액', true, selectedAmount, (newValue) {
              setState(() {
                selectedAmount = newValue;
              });
            }),
            buildTextDropdown('거래 계좌', true, selectedAccount, (newValue) {
              setState(() {
                selectedAccount = newValue;
              });
            }),
            buildTextDropdown('거래 상품', true, selectedGoods, (newValue) {
              setState(() {
                selectedGoods = newValue;
              });
            }),
            buildTextDropdown('비용 종류', false, selectedCategory, (newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            }),
            buildTextDropdown('메모', false, selectedDescription, (newValue) {
              setState(() {
                selectedDescription = newValue;
              });
            }),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.2,
          child:ElevatedButton(
            onPressed: () {
              widget.onButtonPressed();
            },
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: const Text('선택 완료'),
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

class ForthPage extends StatelessWidget {
  final VoidCallback onButtonPressed;

  const ForthPage({required this.onButtonPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
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
    return Container();
  }
}