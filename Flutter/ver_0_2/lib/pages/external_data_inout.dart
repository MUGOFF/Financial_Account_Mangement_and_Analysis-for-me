import 'dart:io';
import 'dart:convert';
// import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:cp949_codec/cp949_codec.dart';
import 'package:ver_0_2/colorsholo.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/synchro_data_grid.dart';
// import 'package:ver_0_2/widgets/models/bank_account.dart';
// import 'package:ver_0_2/widgets/models/card_account.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/loading_widget.dart';
// import 'package:ver_0_2/widgets/models/expiration_investment.dart';
// import 'package:ver_0_2/widgets/models/nonexpiration_investment.dart';

/// 입출력 페이지 구성
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

/// 외부 데이터 입력 위젯
class TableDataIn extends StatelessWidget {
  
/// 외부 데이터 입력 탭
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
                      child: const Column(
                        mainAxisSize:  MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BookDialogContent(),
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
              backgroundColor: HoloColors.shioriNovella
            ),
            child: const AutoSizeText('데이터 \n업로드', style: TextStyle(fontSize: 36, color: Colors.white), maxLines: 2),
          ),
        ),
      ],
    );
  }
}

/// 외부 데이터 입력 모달 위젯
class BookDialogContent extends StatefulWidget {
  /// 외부 데이터 입력 모달 
  const BookDialogContent({super.key});

  @override
 State<BookDialogContent> createState() => _BookDialogContentState();
}

class _BookDialogContentState extends State<BookDialogContent> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  FilePickerResult? filePicked;
  String fileCodec = 'UTF8';
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
          height:_currentPageIndex > 0 ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.4,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: [
              /// 파일 선택 페이지
              FirstPage(
                onFilePathSelected: (path, codec) {
                  setState(() {
                    filePicked = path;
                    fileCodec = codec;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              /// 카테고리 정보 연결 페이지
              SecondPage(
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
                fileCodec: fileCodec,
              ),
              /// 데이터 형식 판별 페이지
              LastPage(
                onButtonPressed: () {
                  Navigator.of(context).pop();
                },
                filePicked: filePicked,
                fileCodec: fileCodec,
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

class FirstPage extends StatefulWidget {
  final Function(FilePickerResult?, String) onFilePathSelected;

  /// onFilePathSelected: 외부 파일 선택 시 발동 함수
  ///
  /// - 외부 위젯으로 값(파일) 전달
  const FirstPage({required this.onFilePathSelected, super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  Future<void> _pickFile() async {
    final Logger logger = Logger();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
        allowMultiple: false,
        withData: true,
      );
      if (result != null) {
        final String filePath = result.files.single.path!;
        final String extension = filePath.split('.').last.toLowerCase();
         if (extension == 'csv') {
          try {
            logger.d('CP949 TRY');
            var input = await File(result.files.single.path!).readAsBytes();
            var fields = const CsvToListConverter().convert(const CP949Codec().decoder.convert(input));
            if (fields.isNotEmpty) {
              widget.onFilePathSelected(result, 'CP949');
              logger.i('CP949 END');
            } 
          } catch(e) {
            logger.e('Error picking file type CP949: $e');
            logger.d('UTF8 TRY');
            try {
              var input = File(result.files.single.path!).openRead();
              var fields = await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList();
              if (fields.isNotEmpty) {
                widget.onFilePathSelected(result, 'UTF8');
                logger.i('UTF8 END');
              } 
            } catch (e) {
              logger.e('Error picking file type or format: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error picking file type or format')),
                );
              }
            }
          }
         } else if (extension == 'xlsx') {
          try {
            logger.d('XLSX TRY');
            final bytes = File(filePath).readAsBytesSync();
            final excel = Excel.decodeBytes(bytes);

            // 첫 시트 기준으로 데이터 추출 (원하면 수정 가능)
            final Sheet sheet = excel.tables[excel.tables.keys.first]!;
            List<List<dynamic>> excelData = [];
            logger.d('sheet check');
            for (List<Data?> row in sheet.rows) {
              excelData.add(row.map((cell) => cell?.value ?? '').toList());
            }
            logger.d('sheet end');

            if (excelData.isNotEmpty) {
              widget.onFilePathSelected(result, 'XLSX');
              logger.i('XLSX END');
              return;
            } else {
              logger.w('No data found in the selected XLSX file.');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('XLSX 파일 첫번째 시트트에 데이터가 없습니다.')),
                );
              }
            }
          } catch (e) {
            logger.e('Error XLSX: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('XLSX 파일을 읽을 수 없습니다.')),
              );
            }
          }
        }
      } else {
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
            // child: const Text('.csv(UTF-8)'),
            child: const Text('업로드 파일 선택', style: TextStyle(fontSize: 24)),
          ),
        ),
        
      ],
    );
  }
}

///세번쨰 페이지, 칼럼 정렬
class SecondPage extends StatefulWidget {
  final FilePickerResult? filePicked;
  final String fileCodec;
  final Function(List<dynamic>, List<dynamic>) onButtonPressed;

  /// onButtonPressed: 다음 페이지 선택 시 발동 함수
  /// 
  /// - 외부 위젯으로 값 전달
  const SecondPage({required this.filePicked, required this.fileCodec, required this.onButtonPressed, super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final Logger logger = Logger();
  List<String> columnNames = [];
  List<dynamic> relationColumnandValue =List.filled(7, null);
  List<dynamic> relationColumnandselectedAccount = [];
  List<List<dynamic>> dataRows = [];
  String? selectedTransactionTime;
  String? selectedAmount;
  String? selectedGoods;
  String? selectedCategory;
  String? selectedCategoryType;
  String? selectedDescription;
  String? selectedInstallment;


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
        List<List<dynamic>> fields = [];


        if (fileName != null && fileName.endsWith('.xlsx')) {
          final bytes = await File(fileName).readAsBytes();
          final excel = Excel.decodeBytes(bytes);
          final Sheet sheet = excel.tables[excel.tables.keys.first]!;

          for (List<Data?> row in sheet.rows) {
            fields.add(row.map((cell) => cell?.value ?? '').toList());
          }
        } else if (widget.fileCodec == 'UTF8') {
          var input = File(fileName!).openRead();
          fields = await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList();
        } else {
          var input =await File(fileName!).readAsBytes();
          fields = const CsvToListConverter().convert(const CP949Codec().decoder.convert(input));
        }
        if (fields.isNotEmpty) {
          columnNames = fields.first.map((field) => field.toString().trim()).where((field) => field.isNotEmpty).toList();
          dataRows = fields.skip(1).toList();    
          setState(() {
            selectedTransactionTime = findMatchingColumn('transactionTime', '날짜', 0);
            selectedAmount = findMatchingColumn('amount', '금액', 1);
            selectedGoods = findMatchingColumn('goods', '상품', 2);
            selectedCategory = findMatchingColumn('category', '카테고리', 3);
            selectedCategoryType = findMatchingColumn('categoryType', '타입', 4);
            selectedDescription = findMatchingColumn('memo', '메모', 5);
            selectedInstallment = findMatchingColumn('installment', '할부', 6);
          });
          // logger.d(columnNames); 
        }
      }
    } catch (e) {
      logger.e('Error while processing the file: $e');
    }
  }
  /// [transactionTime,amount, account, goods, category, categoryType, memo]
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
    return SingleChildScrollView(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('칼럼 정렬', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (widget.filePicked != null)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTextDropdown('거래 날짜', true, selectedTransactionTime, (newValue) {
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
              buildTextDropdown('거래 상품', true, selectedGoods, (newValue) {
                setState(() {
                  selectedGoods = newValue;
                  relationColumnandValue[2] = newValue;
                });
              }),
              buildTextDropdown('거래 타입', false, selectedCategoryType, (newValue) {
                setState(() {
                  selectedCategoryType = newValue;
                  relationColumnandValue[4] = newValue;
                });
              }),
              buildTextDropdown('세부 종류', false, selectedCategory, (newValue) {
                setState(() {
                  selectedCategory = newValue;
                  relationColumnandValue[3] = newValue;
                });
              }),
              buildTextDropdown('메모', false, selectedDescription, (newValue) {
                setState(() {
                  selectedDescription = newValue;
                  relationColumnandValue[5] = newValue;
                });
              }),
              buildTextDropdown('할부', false, selectedInstallment, (newValue) {
                setState(() {
                  selectedInstallment = newValue;
                  relationColumnandValue[6] = newValue;
                });
              }),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4*0.2,
            child:ElevatedButton(
              onPressed: isButtonEnabled() ? () {
                List<dynamic> accountColumnData = [];
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
      ),
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
          items: [
            const  DropdownMenuItem<String>(
              value: null,  // null 값을 가지는 '----' 항목
              child: Text('----'),
            ),
            ...columnNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class LastPage extends StatefulWidget {
  final VoidCallback onButtonPressed;
  final FilePickerResult? filePicked;
  final String fileCodec;
  final List<dynamic> modelColumnrelations;
  final List<dynamic> setData;

  const LastPage({required this.filePicked, required this.fileCodec, required this.onButtonPressed, required this.modelColumnrelations, required this.setData, super.key});

  @override
  State<LastPage> createState() => _LastPageState();
}

class _LastPageState extends State<LastPage> {
  final Logger logger = Logger();
  bool? isDateOnly = false;
  bool isProcessing = false;
  String? fileFromat;
  String? dateFormat;
  final List<String> dateFormats = [
    'yyyy.MM.dd',
    'yyyy-MM-dd',
    'yyyy/MM/dd',
    'yyyy년 MM월 dd일',
    'dd/MM/yyyy',
    'dd.MM.yyyy',
    'MM.dd.yyyy',
    'MM/dd/yyyy',
  ];
  final List<String> timeFormats = [
    'hh:mm',
    'hh시 mm분',
  ];
  final List<String> datetimeFormats = [];
  List<String> columnNames = [];
  List<List<dynamic>> dataRows = [];
  List<dynamic>? relationColumnandValue;
  List<String> accountNames = [];
  List<String> yearlyExpenseCategory = [];


  @override
  void initState() {
    super.initState();
    relationColumnandValue = List.filled(widget.setData.length, null);
    if (widget.filePicked != null) {
      _readColumnNames(widget.filePicked!);
    }
    // _readAccountsinDatabase();
  }

  Future<void> _readColumnNames(FilePickerResult filePicked) async {
    try {
      if (filePicked.files.isNotEmpty) {
        String? fileName = filePicked.files.single.path;
        List<List<dynamic>> fields = [];
        if (fileName != null && fileName.endsWith('.xlsx')) {
          fileFromat = 'xlsx';
          final bytes = await File(fileName).readAsBytes();
          final excel = Excel.decodeBytes(bytes);
          final Sheet sheet = excel.tables[excel.tables.keys.first]!;

          for (List<Data?> row in sheet.rows) {
            fields.add(row.map((cell) => cell?.value ?? '').toList());
          }
        } else if (widget.fileCodec == 'UTF8') {
          var input = File(fileName!).openRead();
          fileFromat = 'csv';
          fields = await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList();
        } else {
          var input =await File(fileName!).readAsBytes();
          fileFromat = 'csv';
          fields = const CsvToListConverter().convert(const CP949Codec().decoder.convert(input));
        }
        // var input = File(fileName!).openRead();
        // var fields = widget.fileCodec == 'UTF8'
        //   ? await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList()
        //   : await input.transform(const CP949Codec().decoder).transform(const CsvToListConverter()).toList();
        if (fields.isNotEmpty) {
          columnNames = fields.first.map((field) => field.toString()).toList();
          dataRows = fields.skip(1).toList();
          // logger.d(dataRows);
        }
      }
      yearlyExpenseCategory = (await DatabaseAdmin().getYearlyExpenseCategories()).itemList ?? [];
    } catch (e) {
      logger.e('Error while processing the file: $e');
    }
  }

  bool isButtonEnabled(List<dynamic>? relationColumnandValue) {
    return relationColumnandValue != null && !relationColumnandValue.contains(null);
  }

  int? parseToInt(dynamic variable) {
    if (variable is int) {
      return variable;
    } else if (variable is String) {
      return int.tryParse(variable.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    return 0;
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('추가 선택', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (widget.filePicked != null)
          Expanded(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('날짜시간 포맷', style: TextStyle(fontSize: 20)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('시간 제외', style: TextStyle(fontSize: 10)),
                        Checkbox(
                          value: isDateOnly,
                          onChanged: (bool? value) {
                            setState(() {
                              isDateOnly = value;
                              if (value!) {
                                dateFormat = dateFormats[0];
                              } else {
                                dateFormat = datetimeFormats[0];
                              }
                            });
                          },
                        ),      
                      ]
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: dateFormat,
                      items: isDateOnly!? dateFormats.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList() : datetimeFormats.map((String value) {
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
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4*0.2,
            child:ElevatedButton(
              onPressed: isButtonEnabled(relationColumnandValue) ? () {
                widget.onButtonPressed();
                insertDatasToDatabase(context, dataRows);
              } : null,
              style: ElevatedButton.styleFrom(
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
              child: const Text('선택 완료'),
            ),
          ),
        ],
      ),
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

  // Future<void> insertDatasToDatabase(BuildContext context, List<List<dynamic>> dataRows) async {
  //   LoadingDialog.show(context, message: "데이터 처리 중...");

  //   try {
  //     await TransactionIsolate.start(dataRows);

  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('데이터 삽입 완료!')),
  //       );
  //     }
  //   } catch (e) {
  //     logger.e('error: $e');
  //   }

  //   LoadingDialog.hide();
  // }

  


  /// modelColumnrelations = [transactionTime, amount, goods, category, categoryType, memo. installment]
  Future<void> insertDatasToDatabase(BuildContext context, List<List<dynamic>> dataRows) async{
    int i = 0;
    try {
      LoadingDialog.show(context, message: "데이터 처리 중...");
      for (var row in dataRows) {
        i++;
        if (fileFromat == 'csv') {
          var rawDate = row[columnNames.indexOf(widget.modelColumnrelations[0])];
          DateTime parsedDate;
          if (rawDate is String) {
            parsedDate = DateFormat(dateFormat).parse(rawDate);
          } else if (rawDate is DateTime) {
            parsedDate = rawDate;
          } else {
            throw Exception('Unsupported date format: $rawDate');
          }
          String formattedDatetime = DateFormat('yyyy년 MM월 dd일THH:mm').format(parsedDate);
          String formattedcategory = widget.modelColumnrelations[3] != null ? row[columnNames.indexOf(widget.modelColumnrelations[3])] : "";
          String formattedcategoryType = widget.modelColumnrelations[4] == null ? "이체" : ['소비', '수입', '이체'].contains(row[columnNames.indexOf(widget.modelColumnrelations[4])]) ? row[columnNames.indexOf(widget.modelColumnrelations[4])] : "이체";
          int? formattedInstallment  = widget.modelColumnrelations[6] != null ? parseToInt(row[columnNames.indexOf(widget.modelColumnrelations[6])]) : 1;
          try {
            MoneyTransaction transaction = MoneyTransaction(
              transactionTime: formattedDatetime,
              amount: double.parse(row[columnNames.indexOf(widget.modelColumnrelations[1])].toString()),
              goods: row[columnNames.indexOf(widget.modelColumnrelations[2])].toString(),
              category: formattedcategory,
              categoryType: formattedcategoryType,
              installation: formattedInstallment ?? 1,
              description: widget.modelColumnrelations[5] != null 
              ? yearlyExpenseCategory.contains(formattedcategory) 
                ? '${row[columnNames.indexOf(widget.modelColumnrelations[5])].toString()} #연간예산 '
                : row[columnNames.indexOf(widget.modelColumnrelations[5])].toString()
              : yearlyExpenseCategory.contains(formattedcategory) 
                ? "#연간예산 "
                : "",
              extraBudget: yearlyExpenseCategory.contains(formattedcategory) ? true : false,
            );
            bool exists = await DatabaseAdmin().checkIfTransCodeExists(
              transaction.transactionTime,
              transaction.goods,
              transaction.amount,
            );
            if (!exists) {
              try {
                await DatabaseAdmin().insertMoneyTransaction(transaction);
              } catch (e) {
                logger.e('error: $e, not enough row data: $row');
              }
            }
            // logger.i('${context.mounted} $processedCount');
          } catch(e) {
            logger.e('error: $e, formData row: $row');
          }
          LoadingDialog.updateProgress(((i) / dataRows.length) * 100);
        ///엑셀의 경우
        } else {
          // logger.d('엑셀의 경우');
          var rawDate = row[columnNames.indexOf(widget.modelColumnrelations[0])];
          DateTime parsedDate;
          if (rawDate is DateCellValue) {
            logger.i(rawDate);
            logger.i(rawDate.asDateTimeUtc());
            logger.i(rawDate.toString());
            parsedDate = rawDate.asDateTimeUtc();
            // logger.i('엑셀의 경우 $parsedDate');
          } else if (rawDate is DateTimeCellValue) {
            logger.i(rawDate);
            logger.i(rawDate.asDateTimeUtc());
            logger.i(rawDate.toString());
            parsedDate = rawDate.asDateTimeUtc();
            logger.i('엑셀의 경우 $parsedDate');
          } else {
            logger.d(rawDate.runtimeType);
            throw Exception('Unsupported date format: $rawDate');
          }
          TextCellValue rawCategory = row[columnNames.indexOf(widget.modelColumnrelations[3])];
          // logger.i('엑셀의 경우 $rawCategory');
          TextCellValue rawCategoryType = row[columnNames.indexOf(widget.modelColumnrelations[4])];
          // logger.i('엑셀의 경우 $rawCategoryType');
          var rawInstallment = widget.modelColumnrelations[6] != null ? row[columnNames.indexOf(widget.modelColumnrelations[6])] : const IntCellValue(1);
          int parsedInstallment;
          // logger.i(rawInstallment);
          if (rawInstallment is IntCellValue) {
            parsedInstallment = rawInstallment.value;
          } else if(rawInstallment is TextCellValue) {
            parsedInstallment = int.tryParse(rawInstallment.toString()) ?? 1;
          } else {
            throw Exception('Unsupported text or int format: $rawInstallment');
          }
          String formattedDatetime = DateFormat('yyyy년 MM월 dd일THH:mm').format(parsedDate);
          String formattedcategory = widget.modelColumnrelations[3] != null ? rawCategory.toString() : "";
          String formattedcategoryType = widget.modelColumnrelations[4] == null ? "이체" : ['소비', '수입', '이체'].contains(rawCategoryType.toString()) ? rawCategoryType.toString() : "이체";
          int? formattedInstallment  = widget.modelColumnrelations[6] != null ? parsedInstallment : 1;
          var rawAmount = row[columnNames.indexOf(widget.modelColumnrelations[1])];
          double parsedAmount;
          if (rawAmount is IntCellValue) {
            parsedAmount = rawAmount.value.toDouble();
          } else if(rawAmount is TextCellValue) {
            parsedAmount = double.tryParse(rawAmount.toString()) ?? 0.0;
          } else if(rawAmount is DoubleCellValue) {
            parsedAmount = rawAmount.value;
          } else {
            throw Exception('Unsupported double format: $rawAmount');
          }
          // logger.d(widget.modelColumnrelations[5]);
          try {
            MoneyTransaction transaction = MoneyTransaction(
              transactionTime: formattedDatetime,
              amount: parsedAmount,
              goods: row[columnNames.indexOf(widget.modelColumnrelations[2])].toString(),
              category: formattedcategory,
              categoryType: formattedcategoryType,
              installation: formattedInstallment,
              description: widget.modelColumnrelations[5] != null 
              ? yearlyExpenseCategory.contains(formattedcategory) 
                ? '${row[columnNames.indexOf(widget.modelColumnrelations[5])].toString()} #연간예산 '
                : row[columnNames.indexOf(widget.modelColumnrelations[5])].toString()
              : yearlyExpenseCategory.contains(formattedcategory) 
                ? "#연간예산 "
                : "",
              extraBudget: yearlyExpenseCategory.contains(formattedcategory) ? true : false,
            );
            bool exists = await DatabaseAdmin().checkIfTransCodeExists(
              transaction.transactionTime,
              transaction.goods,
              transaction.amount,
            );
            if (!exists) {
              try {
                await DatabaseAdmin().insertMoneyTransaction(transaction);
              } catch (e) {
                logger.e('error: $e, not enough row data: $row');
              }
            }
            // logger.i('${context.mounted} $processedCount');
          } catch(e) {
            logger.e('error: $e, formData row: $row');
          }
          LoadingDialog.updateProgress(((i) / dataRows.length) * 100);
        }
      }
    } catch(e) {
      logger.e('error: $e, formmating error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error file format type')),
        );
      }
    } finally {
      logger.d('${context.mounted} fianl');
      LoadingDialog.hide();
      if(context.mounted) {
        Navigator.of(context).pop();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('데이터 삽입 완료!')),
        // );
      }
    }
  }
}

// class TransactionIsolate {
//   static Future<void> start(List<List<dynamic>> dataRows) async {
//     final receivePort = ReceivePort();
//     await Isolate.spawn(_processAndInsertTransactions, receivePort.sendPort);
    
//     final sendPort = await receivePort.first as SendPort;
//     final responsePort = ReceivePort();
    
//     sendPort.send([dataRows, responsePort.sendPort]);
    
//     await for (var message in responsePort) {
//       if (message == "done") {
//         break;
//       }
//     }

//     receivePort.close();
//     responsePort.close();
//   }

//   static void _processAndInsertTransactions(SendPort sendPort) async {
//     final port = ReceivePort();
//     sendPort.send(port.sendPort);
    
//     await for (var message in port) {
//       if (message is List) {
//         List<List<dynamic>> dataRows = message[0];
//         SendPort replyPort = message[1];

//         for (var row in dataRows) {
//           try {
//             // 데이터 변환
//             String formattedDatetime = DateFormat('yyyy년 MM월 dd일THH:mm')
//                 .format(DateFormat(dateFormat).parse(row[columnNames.indexOf(widget.modelColumnrelations[0])])); 
//             String formattedCategory = widget.modelColumnrelations[3] != null
//                 ? row[columnNames.indexOf(widget.modelColumnrelations[3])]
//                 : "";
//             String formattedCategoryType = widget.modelColumnrelations[4] == null
//                 ? "이체"
//                 : ['소비', '수입', '이체'].contains(row[columnNames.indexOf(widget.modelColumnrelations[4])])
//                     ? row[columnNames.indexOf(widget.modelColumnrelations[4])]
//                     : "이체";
//             int? formattedInstallment = widget.modelColumnrelations[6] != null
//                 ? parseToInt(row[columnNames.indexOf(widget.modelColumnrelations[6])])
//                 : 1;

//             MoneyTransaction transaction = MoneyTransaction(
//               transactionTime: formattedDatetime,
//               amount: double.parse(row[columnNames.indexOf(widget.modelColumnrelations[1])].toString()),
//               goods: row[columnNames.indexOf(widget.modelColumnrelations[2])].toString(),
//               category: formattedCategory,
//               categoryType: formattedCategoryType,
//               installation: formattedInstallment ?? 1,
//               description: widget.modelColumnrelations[5] != null
//                   ? yearlyExpenseCategory.contains(formattedCategory)
//                       ? '${row[columnNames.indexOf(widget.modelColumnrelations[5])].toString()} #연간예산 '
//                       : row[columnNames.indexOf(widget.modelColumnrelations[5])].toString()
//                   : yearlyExpenseCategory.contains(formattedCategory)
//                       ? "#연간예산 "
//                       : "",
//               extraBudget: yearlyExpenseCategory.contains(formattedCategory),
//             );

//             // 데이터베이스에 삽입
//             bool exists = await DatabaseAdmin().checkIfTransCodeExists(
//               transaction.transactionTime,
//               transaction.goods,
//               transaction.amount,
//             );

//             if (!exists) {
//               await DatabaseAdmin().insertMoneyTransaction(transaction);
//             }
//           } catch (e) {
//             logger.e('error: $e, formData row: $row');
//           }
//         }

//         replyPort.send("done");
//       }
//     }
//   }
// }


class TableDataOut extends StatefulWidget {
  const TableDataOut({super.key});

  @override
  State<TableDataOut> createState() => _TableDataOutState();
}

class _TableDataOutState extends State<TableDataOut> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.download,
          size: 100.0,
        ),
        SizedBox(height: 50),
        DataGridExportExample(),
      ],
    );
    // return const Text("업데이트 예정");
  }
}