import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
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
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/loading_widget.dart';

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

// /// 외부 데이터 입력 위젯
// class TableDataIn extends StatelessWidget {
  
// /// 외부 데이터 입력 탭
//   const TableDataIn({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Icon(
//           Icons.drive_folder_upload_rounded,
//           size: 100.0,
//         ),
//         const SizedBox(height: 50),
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.6,
//           height: MediaQuery.of(context).size.height * 0.4*0.3,
//           child: ElevatedButton(
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return Dialog(
//                     child: SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       child: const Column(
//                         mainAxisSize:  MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           BookDialogContent(),
//                         ],
//                       ) 
//                     )
//                   );
//                 },
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(30.0), // 원하는 모양으로 조절
//               ),
//               backgroundColor: HoloColors.shioriNovella
//             ),
//             child: const AutoSizeText('데이터 \n업로드', style: TextStyle(fontSize: 36, color: Colors.white), maxLines: 2),
//           ),
//         ),
//       ],
//     );
//   }
// }

class TableDataIn extends StatelessWidget {
  const TableDataIn({super.key});

  Future<void> _pickFileAndOpenDialog(BuildContext context) async {
    final Logger logger = Logger();
    FilePickerResult? result;
    String selectedCodec = 'UTF8';

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        // 로딩 다이얼로그 먼저 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final String filePath = result.files.single.path!;
        final String extension = filePath.split('.').last.toLowerCase();
        int initialPage = (extension == 'xlsx') ? 0 : 1;

        if (extension == 'csv') {
          try {
            var input = await File(filePath).readAsBytes();
            var fields = const CsvToListConverter().convert(const CP949Codec().decoder.convert(input));
            if (fields.isNotEmpty) selectedCodec = 'CP949';
          } catch (e) {
            try {
              var input = File(filePath).openRead();
              var fields = await input.transform(const Utf8Codec().decoder).transform(const CsvToListConverter()).toList();
              if (fields.isNotEmpty) selectedCodec = 'UTF8';
            } catch (e) {
              logger.e('CSV decoding failed for both codecs.');
              return;
            }
          }
        } else if (extension == 'xlsx') {
          try {
            // final bytes = File(filePath).readAsBytesSync();
            // final excel = Excel.decodeBytes(bytes);
            // final Sheet sheet = excel.tables[excel.tables.keys.first]!;
            // if (sheet.rows.isEmpty) return;
            selectedCodec = 'XLSX';
          } catch (e) {
            logger.e('XLSX decoding failed: $e');
            return;
          }
        }

        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 파일 선택 후 모달 열기 (SecondPage부터 시작)
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: BookDialogContent(
                  filePicked: result,
                  fileCodec: selectedCodec,
                  initialPage: initialPage,
                ),
              ),
            ),
          );
        }
      }
    } catch (e) {
      logger.e('파일 선택 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일부 항목이 적절하지 않은 타입으로 설정되있습니다')),
      );
      Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.drive_folder_upload_rounded, size: 100.0),
        const SizedBox(height: 50),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4 * 0.3,
          child: ElevatedButton(
            onPressed: () => _pickFileAndOpenDialog(context),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              backgroundColor: HoloColors.shioriNovella,
            ),
            child: const AutoSizeText(
              '데이터 \n업로드',
              style: TextStyle(fontSize: 36, color: Colors.white),
              maxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

/// 외부 데이터 입력 모달 위젯
class BookDialogContent extends StatefulWidget {
  final FilePickerResult? filePicked;
  final String fileCodec;
  final int initialPage;
  /// 외부 데이터 입력 모달 
  const BookDialogContent({super.key, required this.initialPage, this.filePicked, this.fileCodec = 'UTF8'});

  @override
 State<BookDialogContent> createState() => _BookDialogContentState();
}

class _BookDialogContentState extends State<BookDialogContent> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  String sheetName = '';
  List<dynamic> modelColumnrelations = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          height: min(max(MediaQuery.of(context).size.height * 0.6, 600),MediaQuery.of(context).size.height * 0.9),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            children: [
              // 시트트 선택 페이지
              FirstPage(
                onFileSheetSelected: (sheetNameSelected) {
                  setState(() {
                    sheetName = sheetNameSelected;
                    // fileCodec = codec;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                filePicked: widget.filePicked,
              ),
              /// 카테고리 정보 연결 페이지
              SecondPage(
                onButtonPressed: (realtion) {
                  setState(() {
                    modelColumnrelations = realtion;
                  });
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }, 
                filePicked: widget.filePicked,
                fileCodec: widget.fileCodec,
                xlsxSheet: sheetName,
              ),
              /// 데이터 형식 판별 페이지
              LastPage(
                onButtonPressed: () {
                  Navigator.of(context).pop();
                },
                filePicked: widget.filePicked,
                fileCodec: widget.fileCodec,
                modelColumnrelations: modelColumnrelations,
                xlsxSheet: sheetName,
              ),
            ],
          ),
        ),
      ]
    );
  }
}

class FirstPage extends StatefulWidget {
  final FilePickerResult? filePicked;
  final Function(String) onFileSheetSelected;

  /// onFileSheetSelected: 외부 파일 선택 시 발동 함수
  ///
  /// - 외부 위젯으로 값(파일) 전달
  const FirstPage({required this.filePicked, required this.onFileSheetSelected, super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  Map<String, Sheet> fileSheets = {};
  String? selectedSheet;

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    final Logger logger = Logger();
    try {
      if (widget.filePicked != null) {
        final String filePath = widget.filePicked!.files.single.path!;
        final String extension = filePath.split('.').last.toLowerCase();
         if (extension != 'xlsx') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('XLSX 파일을 읽을 수 없습니다.')),
            );
          }
          Navigator.of(context).pop();
         } else  {
          try {
            logger.d('XLSX READ TRY');
            final bytes = File(filePath).readAsBytesSync();
            final excel = Excel.decodeBytes(bytes);

            setState(() {
              fileSheets = excel.tables;
              if (fileSheets.isNotEmpty) {
                selectedSheet = fileSheets.keys.first;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('XLSX 파일이 비어있습니다.')),
                );
                Navigator.of(context).pop();
              }
            });
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
        const Text('시트 선택', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: DropdownButtonFormField<String>(
            value: selectedSheet,
            items: fileSheets.keys.map((sheetName) {
              return DropdownMenuItem<String>(
                value: sheetName,
                child: Text(sheetName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedSheet = value;
              });
            },
            decoration: const InputDecoration(
              labelText: '시트를 선택하세요',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.3,
          child:ElevatedButton(
            onPressed: selectedSheet != null
              ? () {
                  widget.onFileSheetSelected(selectedSheet!);
                }
              : null,
            style: ElevatedButton.styleFrom(
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            // child: const Text('.csv(UTF-8)'),
            child: const Text('파일 시트 선택', style: TextStyle(fontSize: 24)),
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
  final String? xlsxSheet;
  final Function(List<dynamic>) onButtonPressed;

  /// onButtonPressed: 다음 페이지 선택 시 발동 함수
  /// 
  /// - 외부 위젯으로 값 전달
  const SecondPage({required this.filePicked, required this.fileCodec, required this.onButtonPressed, this.xlsxSheet, super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final Logger logger = Logger();
  List<String> columnNames = [];
  List<dynamic> relationColumnandValue =List.filled(8, null);
  List<List<dynamic>> dataRows = [];
  String? selectedTransactionTime;
  String? selectedAmount;
  String? selectedGoods;
  String? selectedCategory;
  String? selectedCategoryType;
  String? selectedDescription;
  String? selectedInstallment;
  String? selectedCredit;

  static const requiredFields = [0, 1, 2]; // 날짜, 금액, 상품

  static const fieldLabels = [
    '거래 날짜',
    '거래 금액',
    '거래 상품',
    '거래 종류(대분류)',
    '카테 고리(소분류)',
    '메모',
    '할부',
    '신용',
  ];

  static const fieldKeywords = [
    ['transactionTime', '일시'],
    ['amount', '금액'],
    ['goods', '명칭'],
    ['categoryType', '분류'],
    ['category', '카테고리'],
    ['memo', '메모'],
    ['installment', '할부'],
    ['credit', '신용'],
  ];

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
          final Sheet sheet = excel.tables[widget.xlsxSheet]!;

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
            _autoMatchColumns();
          });
        }
      }
    } catch (e) {
      logger.e('Error while processing the file: $e');
    }
  }

  void _autoMatchColumns() {
    for (int i = 0; i < fieldKeywords.length; i++) {
      for (final keyword in fieldKeywords[i]) {
        final match = columnNames.firstWhere(
          (col) => col.toLowerCase().contains(keyword.toLowerCase()),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          relationColumnandValue[i] = match;
          break;
        }
      }
    }
  }

  bool isButtonEnabled() {
    return requiredFields.every((index) => relationColumnandValue[index] != null);
  }

  Future<void> _onButtonPressed(List<dynamic> relationColumnandValue) async {
    final Logger logger = Logger();
    try {
      widget.onButtonPressed(relationColumnandValue);
    } catch (e) {
      logger.e('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('칼럼 정렬', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (widget.filePicked != null)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._buildColumnMappingDropdowns(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4*0.2,
            child:ElevatedButton(
              onPressed: isButtonEnabled() ? () {
                _onButtonPressed(relationColumnandValue);
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

  List<Widget> _buildColumnMappingDropdowns() {
    return List.generate(fieldLabels.length, (index) {
      return buildTextDropdown(
        fieldLabels[index],
        requiredFields.contains(index),
        relationColumnandValue[index],
        (newValue) {
          setState(() {
            relationColumnandValue[index] = newValue;
          });
        },
      );
    });
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
  final String? xlsxSheet;
  final List<dynamic> modelColumnrelations;

  const LastPage({required this.filePicked, required this.fileCodec, required this.onButtonPressed, required this.modelColumnrelations, this.xlsxSheet, super.key});

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
    relationColumnandValue = List.filled(widget.modelColumnrelations.length, null);
    if (widget.filePicked != null) {
      _readColumnNames(widget.filePicked!).then((_) {
        if (fileFromat == 'xlsx') {
          WidgetsBinding.instance.addPostFrameCallback((_) async{
            // widget.onButtonPressed();
            showLoadingAndStart(context, dataRows);
          });
        }
      });
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
          final Sheet sheet = excel.tables[widget.xlsxSheet]!;

          for (List<Data?> row in sheet.rows) {
            List<dynamic> mappedRow = row.map((cell) => cell?.value ?? '').toList();
            if (mappedRow.every((element) => element.toString().trim().isEmpty)) {
              continue;
            }
            fields.add(mappedRow);
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
 


  /// modelColumnrelations = [transactionTime, amount, goods, category, categoryType, memo. installment]
  Future<void> insertDatasToDatabase(BuildContext context, List<List<dynamic>> dataRows) async{
    int i = 0;
    try {
      await LoadingDialog.show(context, message: "데이터 처리 중...");
      await Future.delayed(const Duration(milliseconds: 100));
      for (var row in dataRows) {
        i++;
        // if (fileFromat == 'csv') {
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
        String formattedcategoryType = widget.modelColumnrelations[3] == null ? "이체" : ['소비', '수입', '이체'].contains(row[columnNames.indexOf(widget.modelColumnrelations[4])]) ? row[columnNames.indexOf(widget.modelColumnrelations[4])] : "이체";
        String formattedcategory = widget.modelColumnrelations[4] != null ? row[columnNames.indexOf(widget.modelColumnrelations[3])] : "";
        int? formattedInstallment  = widget.modelColumnrelations[6] != null ? parseToInt(row[columnNames.indexOf(widget.modelColumnrelations[6])]) : 1;
        bool formattedCredit  = widget.modelColumnrelations[7] != null ? ['1','신용','신용카드', 'O'].contains(row[columnNames.indexOf(widget.modelColumnrelations[7])]) : false;
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
            credit: formattedCredit ? true : false,
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

  void showLoadingAndStart(BuildContext context, List<List<dynamic>> dataRows) {
    LoadingDialog.show(
      context,
      message: "데이터 처리 중...",
      onReady: () async {
        await autoInsertDatasToDatabase(context, dataRows); // 여기서는 dialog를 띄우지 않음
        LoadingDialog.hide(); // 모든 작업 끝나면 다이얼로그 닫기
      },
    );
  }

  ///xlsx의 경우 처리
  Future<void> autoInsertDatasToDatabase(BuildContext context, List<List<dynamic>> dataRows) async{
    int i = 0;
    try {
      for (var row in dataRows) {
        i++;
        //날짜
        var rawDate = row[columnNames.indexOf(widget.modelColumnrelations[0])];
        DateTime parsedDate;
        if (rawDate == null || rawDate == '') {
          continue;
        }
        if (rawDate is DateCellValue || rawDate is DateTimeCellValue) {
          parsedDate = rawDate.asDateTimeUtc();
        } else {
          logger.d('e');
          throw Exception('Date');
        }
        String formattedDatetime = DateFormat('yyyy년 MM월 dd일THH:mm').format(parsedDate);
        //금액
        var rawAmount = row[columnNames.indexOf(widget.modelColumnrelations[1])];
        double parsedAmount;
        if (rawAmount is IntCellValue) {
          parsedAmount = rawAmount.value.toDouble();
        } else if(rawAmount is TextCellValue || rawAmount is String) {
          parsedAmount = double.tryParse(rawAmount.toString()) ?? 0.0;
        } else if(rawAmount is DoubleCellValue) {
          parsedAmount = rawAmount.value;
        } else {
          logger.d('e');
          throw Exception('Amount');
        }
        //항목
        var rawGoods = row[columnNames.indexOf(widget.modelColumnrelations[2])];
        String parsedGoods;
        if(rawGoods is TextCellValue || rawGoods is String) {
          parsedGoods = rawAmount.toString();
        } else {
          logger.d('e');
          throw Exception('Goods');
        }
        //분류
        var rawCategoryType = row[columnNames.indexOf(widget.modelColumnrelations[3])];
        String parsedCategoryType;
        if(rawCategoryType is TextCellValue || rawCategoryType is String) {
          parsedCategoryType = ['소비', '수입', '이체'].contains(rawCategoryType.toString()) ? rawCategoryType.toString() : "이체";
        } else if(rawCategoryType == null) {
          parsedCategoryType = '이체';
        } else {  
          logger.d('e');
          throw Exception('CategoryType');
        }
        //카테고리
        var rawCategory = row[columnNames.indexOf(widget.modelColumnrelations[4])];
        String parsedCategory;
        if(rawCategory is TextCellValue || rawCategory is String) {
          parsedCategory = rawCategoryType.toString();
        } else if(rawCategory == null) {
          parsedCategory = '미기재';
        } else {  
          logger.d('e');
          throw Exception('Category');
        }
        //메모
        var rawDescription = widget.modelColumnrelations[5] != null ? row[columnNames.indexOf(widget.modelColumnrelations[5])] : TextCellValue('');
        //할부
        var rawInstallment = widget.modelColumnrelations[6] != null ? row[columnNames.indexOf(widget.modelColumnrelations[6])] : const IntCellValue(1);
        int parsedInstallment;
        if (rawInstallment is IntCellValue) {
          parsedInstallment = rawInstallment.value;
        } else if(rawInstallment is TextCellValue) {
          parsedInstallment = int.tryParse(rawInstallment.toString()) ?? 1;
        } else {
          logger.d('e');
          throw Exception('Installment');
        }
        //신용
        TextCellValue rawCredit = row[columnNames.indexOf(widget.modelColumnrelations[7])].runtimeType == TextCellValue ? row[columnNames.indexOf(widget.modelColumnrelations[7])] : TextCellValue('check');
        bool formattedCredit =  widget.modelColumnrelations[7] != null ? ['1','신용','신용카드', 'O'].contains(rawCredit.toString()) : false;
        try {
          MoneyTransaction transaction = MoneyTransaction(
            transactionTime: formattedDatetime,
            amount: parsedAmount,
            goods: parsedGoods != '' ? parsedGoods : '미기재',
            category: parsedCategory,
            categoryType: parsedCategoryType,
            installation: parsedInstallment,
            description: yearlyExpenseCategory.contains(parsedCategory) 
              ? '${rawDescription.toString()} #연간예산 '
              : rawDescription.toString(),
            extraBudget: yearlyExpenseCategory.contains(parsedCategory) ? true : false,
            credit: formattedCredit ? true : false,
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
        // }
      }
    } catch(e) {
      logger.e('error: $e, formmating error');
      switch (e) {
        case 'Date':
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('날짜 포맷이 아닙니다')),
            );
          }
          break;
        case 'Installment':
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('할부 항목이 숫자 혹은 텍스트 포맷이 아닙니다')),
            );
          }
          break;
        case 'Amount':
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('금액 항목이 숫자 혹은 텍스트 포맷이 아닙니다')),
            );
          }
          break;
        case 'Goods':
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('내역 항목이 텍스트 포맷이 아닙니다')),
            );
          }
          break;
        case 'CategoryType':
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('거래분류 항목이 텍스트 포맷이 아닙니다')),
            );
          }
          break;
        case 'Category':
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('카테고리 항목이 텍스트 포맷이 아닙니다')),
            );
          }
          break;
        default:
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('일부 항목이 적절하지 않은 타입으로 설정되있습니다')),
            );
          }
      }
    } finally {
      logger.d('${context.mounted} fianl');
      // LoadingDialog.hide();
      if(context.mounted) {
        Navigator.of(context).pop();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('데이터 삽입 완료!')),
        // );
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
  }
}