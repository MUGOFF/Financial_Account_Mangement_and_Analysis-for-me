import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:ver_0_2/colorsholo.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/models/extra_budget_group.dart';

class TransactionGridDataSource extends DataGridSource {
  final List<MoneyTransaction> transanctions;
  TransactionGridDataSource({required this.transanctions}) {
    buildPaginatedDataGridRows();
  }

  Logger logger = Logger();

  String formatterK(num number) {
    String preproNumber;
    if(number % 1 == 0) {
      preproNumber = (number * -1).toStringAsFixed(0);
    } else {
      preproNumber =  (number * -1).toString();
    }

    String newText = preproNumber.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (newText.isEmpty) return "0";

    final double value = double.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(value);

    return formattedText;
  }

  String formatterDate(String dateString) {
    DateFormat dateFormat = DateFormat("yyyy년 MM월 dd일'T'HH:mm");
    String formattedDatetime = DateFormat('yyyy년 MM월 dd일').format(dateFormat.parse(dateString));

    return formattedDatetime;
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AutoSizeText(
            (dataGridCell.columnName == 'Amount')
            ? formatterK(dataGridCell.value)
            : (dataGridCell.columnName == 'Date')
            ? formatterDate(dataGridCell.value)
            : dataGridCell.value.toString(),
            overflow: (dataGridCell.columnName == 'Name')
              ? TextOverflow.ellipsis
              : TextOverflow.clip,
            maxLines: 1,
            style:  const TextStyle(fontSize: 16),
            minFontSize: 12,
          )
        );
    }).toList());
  }

  void buildPaginatedDataGridRows() {
    dataGridRows = transanctions.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'Date', value: dataGridRow.transactionTime),
        DataGridCell<String>(columnName: 'Name', value: dataGridRow.goods),
        DataGridCell<double>(columnName: 'Amount', value: dataGridRow.amount),
        DataGridCell<String>(columnName: 'Category', value: dataGridRow.category),
      ]);
    }).toList(growable: false);
    // logger.i(dataGridRows);
  }
}

class TagDataGrid extends StatefulWidget {
  final String tagName;
  const TagDataGrid({super.key, required this.tagName});

  @override
  State<TagDataGrid> createState() => _TagDataGridState();
}

class _TagDataGridState extends State<TagDataGrid> {
  Logger logger = Logger();
  List<MoneyTransaction> transactionData = <MoneyTransaction>[];
  TransactionGridDataSource? tagTransactionDataSource = TransactionGridDataSource(transanctions: []);
  final int _rowsPerPage = 5;

  @override
  void initState() {
    super.initState();
    getTagTransactionData();
  }
    
  Future<void> getTagTransactionData() async {
    List<MoneyTransaction> fetchedTransactions = await DatabaseAdmin().getTransactionsByTag(widget.tagName);
    // 날짜 형식에 맞는 DateFormat 생성
    DateFormat format = DateFormat("yyyy년 MM월 dd일'T'HH:mm");

    fetchedTransactions.sort((a, b) {
      DateTime dateA = format.parse(a.transactionTime); // String -> DateTime 변환
      DateTime dateB = format.parse(b.transactionTime); // String -> DateTime 변환
      return dateA.compareTo(dateB); // DateTime으로 정렬
    });
    
    setState(() {
      transactionData = fetchedTransactions;
      tagTransactionDataSource = TransactionGridDataSource(transanctions: transactionData);
    });
  }

  
  @override
  Widget build(BuildContext context) {
    // logger.i((transactionData.length / _rowsPerPage).ceilToDouble());
    return Column(
      children: [
        Expanded(
          child: SfDataGrid(
            source: tagTransactionDataSource!,
            columnWidthMode: ColumnWidthMode.fill,
            allowSorting: true,
            allowTriStateSorting: true,
            // allowSwiping: true,
            // swipeMaxOffset: 0.0,
            columns: [
              GridColumn(
                // allowFiltering: false,
                columnName: 'Date',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Date')
                )
              ),
              GridColumn(
                // allowFiltering: false,
                columnName: 'Name',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Name')
                )
              ),
              GridColumn(
                // allowFiltering: false,
                columnName: 'Amount',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Amount')
                )
              ),
              GridColumn(
                allowSorting: false,
                // filterPopupMenuOptions: const FilterPopupMenuOptions(canShowSortingOptions: false, filterMode:FilterMode.checkboxFilter,canShowClearFilterOption: false),
                columnName: 'Category',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Category')
                )
              ),
            ],
          ),
        ),
        SfDataPager(
          delegate: tagTransactionDataSource!,
          pageCount: (transactionData.length / _rowsPerPage) > 0 ? (transactionData.length / _rowsPerPage).ceilToDouble() : 1,
          direction: Axis.horizontal,
        )
      ]
    );
  }
}

///특별 예산 클래스
class ExtraTransactionGrid {
  ExtraTransactionGrid({required this.dataid, required this.name, required this.category, required this.amount, this.modifyCategory});
  final String dataid;
  final String name;
  String category;
  final int amount;
  Function(String)? modifyCategory;
}

class ExtraTransactionSource extends DataGridSource {
  Logger logger = Logger ();
  final TextEditingController _textFieldController = TextEditingController();
  final BuildContext context;
  final List<ExtraTransactionGrid> extraTransaction;
  
  // final Function(String, String)? afterEdit;
  ExtraTransactionSource({
    required this.extraTransaction,
    required this.context,
  }) {
    extraTransactionPage = extraTransaction.length < _rowsPerPage
      ? extraTransaction
      : extraTransaction.getRange(0, _rowsPerPage).toList();
    buildPaginatedDataGridRows();
  }
  List<ExtraTransactionGrid> extraTransactionPage=[];
  final int _rowsPerPage = 5;

  @override
  List<DataGridRow> get rows => dataGridRows;
  
  List<DataGridRow> dataGridRows = [];

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.center,
          child: (dataGridCell.columnName == 'modify')
          ? IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // logger.d(row.getCells()[1].value);
                  // logger.d(dataGridCell.value);
                  _textFieldController.text = row.getCells()[1].value;
                  return AlertDialog(
                  title: const Text('카테고리 수정'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _textFieldController,
                          cursorColor: Colors.transparent,
                          decoration: const InputDecoration(
                            hintText: '카테고리를 입력하세요요', // 힌트 텍스트
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          dataGridCell.value(_textFieldController.text);
                          notifyListeners();
                          Navigator.pop(context);
                        },
                        child: const Text('수정'),
                      ),
                    ],
                  );
                },
              );
            },
          )
          : Text(
            (dataGridCell.columnName == 'amount')
              ?  NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR", ).format(dataGridCell.value.abs()).toString()
              : dataGridCell.value.toString(),    
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    int startIndex = newPageIndex * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    if (startIndex < extraTransaction.length && endIndex <= extraTransaction.length) {
      extraTransactionPage =
          extraTransaction.getRange(startIndex, endIndex).toList(growable: false);
      buildPaginatedDataGridRows();
      notifyListeners();
    } else {
      extraTransactionPage = [];
    }

    return true;
  }

  void buildPaginatedDataGridRows() {
    dataGridRows = extraTransactionPage.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        // DataGridCell<String>(columnName: 'id', value: dataGridRow.dataid),
        DataGridCell<String>(columnName: 'name', value: dataGridRow.name),
        DataGridCell<String>(
            columnName: 'category', value: dataGridRow.category),
        DataGridCell<int>(
            columnName: 'amount', value: dataGridRow.amount),
        DataGridCell<Function>(
            columnName: 'modify', value: dataGridRow.modifyCategory),
      ]);
    }).toList(growable: false);
  }
}

///특별 예산 데이타표
class ExtraBudgetDataGrid extends StatefulWidget {
  final int id;
  final Function updatePageCallback;
  const ExtraBudgetDataGrid({required this.id,required this.updatePageCallback, super.key});

  @override
  State<ExtraBudgetDataGrid> createState() => _ExtraBudgetDataGridState();
}

class _ExtraBudgetDataGridState extends State<ExtraBudgetDataGrid> {
  Logger logger = Logger();
  Map<String, dynamic>? budgetData;
  List<int> selectedTransactionData = [];
  List<Map<String, dynamic>> _tableRawData = [];
  List<ExtraTransactionGrid> tableData = <ExtraTransactionGrid>[];
  List<ExtraTransactionGrid> tableDataPage = <ExtraTransactionGrid>[];
  ExtraTransactionSource? _tableDataSource;
  final int _rowsPerPage = 5;

  @override
  void initState() {
    super.initState();
    fetchBaseDatas();
  }

  Future<void> fetchBaseDatas() async{
    ExtraBudgetGroup? fetchGroupData;
    fetchGroupData = await DatabaseAdmin().getExtraGroupDatasById(widget.id);
    setState(() {
      if(fetchGroupData != null) {
        if (fetchGroupData.dataList!.containsKey('tableData')) {
          budgetData = fetchGroupData.dataList!;
          // logger.d(fetchGroupData.dataList!);
          _tableRawData = List<Map<String, dynamic>>.from(fetchGroupData.dataList!['tableData']);
          fetchTableData();
        }
      }
    });
  }
  void fetchTableData() {
    List<ExtraTransactionGrid> localtableData = [];
    _tableRawData.asMap().forEach((index, rows) {
      selectedTransactionData.add(rows['id']);
      localtableData.add(ExtraTransactionGrid(
        dataid: rows['dataid'],
        name: rows['goods'],
        category: rows['category'],
        amount: rows['amount'],
        modifyCategory: (String category) {
          setState(() {
            _tableRawData[index]['category'] = category;
            updateCategoryDataToDatabase(_tableRawData,widget.id);
            fetchBaseDatas();
            widget.updatePageCallback();
          });
        },
      ));
    });
    setState(() {
      tableData = localtableData;
      selectedTransactionData = selectedTransactionData.toSet().toList();
      _tableDataSource = ExtraTransactionSource(
        extraTransaction: tableData,
        context: context
      );
    });
  } 

  @override
  Widget build(BuildContext context) {
    if (_tableDataSource == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SfDataGridTheme(
            data: SfDataGridThemeData(headerColor: Theme.of(context).colorScheme.inversePrimary),
            child:SfDataGrid(
              source: _tableDataSource!,
              columnWidthMode: ColumnWidthMode.fill,
              headerGridLinesVisibility : GridLinesVisibility.none,
              gridLinesVisibility: GridLinesVisibility.vertical,
              navigationMode: GridNavigationMode.cell,
              selectionMode: SelectionMode.single,
              columns: [
                GridColumn(
                  columnName: 'name',
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ),
                GridColumn(
                  columnName: 'category',
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ),
                GridColumn(
                  columnName: 'amount',
                  label: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ),
                GridColumn(
                  columnName: 'modify',
                  maximumWidth: 40,
                  minimumWidth: 40,
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    )
                  )
                ),
              ],
            ),
          ),
          SfDataPager(
            delegate: _tableDataSource!,
            pageCount: tableData.length / _rowsPerPage > 0 ? (tableData.length / _rowsPerPage) : 1,
            direction: Axis.horizontal,
          )
        ],
      )
    );
  }

  void updateCategoryDataToDatabase(List<Map<String, dynamic>> jsonfyTableData, int id) {
    if (budgetData != null) {
      budgetData!['tableData'] = jsonfyTableData;
    }
    String savedata = json.encode(budgetData);
    DatabaseAdmin().updateExtraJsonData(savedata, id);
  }

}

class TransactionExportGridDataSource extends DataGridSource {
  final List<MoneyTransaction> transanctions;
  TransactionExportGridDataSource({required this.transanctions}) {
    dataGridRows = transanctions
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'Date', value: dataGridRow.transactionTime),
              DataGridCell<String>(columnName: 'Name', value: dataGridRow.goods),
              DataGridCell<double>(columnName: 'Amount', value: dataGridRow.amount),
              DataGridCell<String>(columnName: 'Category', value: dataGridRow.category),
              DataGridCell<String>(columnName: 'CategoryType', value: dataGridRow.categoryType),
              DataGridCell<String>(columnName: 'Description', value: dataGridRow.description),
              DataGridCell<int>(columnName: 'Installation', value: dataGridRow.installation),
              DataGridCell<bool>(columnName: 'Credit', value: dataGridRow.credit),
            ]))
        .toList();
  }

  Logger logger = Logger();

  String formatterK(num number) {
    String preproNumber;
    if(number % 1 == 0) {
      preproNumber = (number * -1).toStringAsFixed(0);
    } else {
      preproNumber =  (number * -1).toString();
    }

    String newText = preproNumber.replaceAll(RegExp(r'[^0-9.-]'), '');
    if (newText.isEmpty) return "0";

    final double value = double.parse(newText);
    final formattedText = NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(value);

    return formattedText;
  }

  String formatterDate(String dateString) {
    DateFormat dateFormat = DateFormat("yyyy년 MM월 dd일THH:mm");
    String formattedDatetime = DateFormat('yyyy-MM-dd HH:mm').format(dateFormat.parse(dateString));

    return formattedDatetime;
  }

  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: AutoSizeText(
            _formatCellValue(dataGridCell),
            overflow: (dataGridCell.columnName == 'Name')
              ? TextOverflow.ellipsis
              : TextOverflow.clip,
            maxLines: 1,
            style:  const TextStyle(fontSize: 16),
            minFontSize: 12,
          )
        );
    }).toList());
  }

  String _formatCellValue(DataGridCell dataGridCell) {
    switch (dataGridCell.columnName) {
      case 'Amount':
        return formatterK(dataGridCell.value);
      case 'Date':
        return formatterDate(dataGridCell.value);
      case 'Credit':
        return dataGridCell.value? 'Credit' : 'Debit';
      default:
        return dataGridCell.value.toString();
    }
  }
}

/// 데이터 내보내기기
class DataGridExportExample extends StatefulWidget {

  const DataGridExportExample({super.key});
  
  @override
  State<DataGridExportExample> createState() => _DataGridExportExampleState();
}

class _DataGridExportExampleState extends State<DataGridExportExample> {
  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();
  Logger logger = Logger();
  List<MoneyTransaction> transactionData = <MoneyTransaction>[];
  TransactionExportGridDataSource transactionDataSource = TransactionExportGridDataSource(transanctions: []);

  @override
  void initState() {
    super.initState();
    getTagTransactionData();
  }
    
  Future<void> getTagTransactionData() async {
    List<MoneyTransaction> fetchedTransactions = await DatabaseAdmin().getExportTransactions();
    // 날짜 형식에 맞는 DateFormat 생성
    DateFormat format = DateFormat("yyyy년 MM월 dd일THH:mm");

    fetchedTransactions.sort((a, b) {
      DateTime dateA = format.parse(a.transactionTime); // String -> DateTime 변환
      DateTime dateB = format.parse(b.transactionTime); // String -> DateTime 변환
      return dateA.compareTo(dateB); // DateTime으로 정렬
    });
    
    setState(() {
      transactionData = fetchedTransactions;
      transactionDataSource = TransactionExportGridDataSource(transanctions: transactionData);
    });
  }

  Future<void> exportToExcel(List<int> bytes) async {
    try {
      final directory = Directory('/storage/emulated/0/Download');
      final filePath = '${directory.path}/BookExport.xlsx';

      final uniqueFilePath = getUniqueFilePath(directory.path, 'BookExport.xlsx');

      final file = File(uniqueFilePath);
      await file.writeAsBytes(bytes, flush: true);

      logger.d('엑셀 파일이 다운로드 경로에 성공적으로 저장되었습니다: $filePath');
      filedropMessage(filePath);
    } catch (e) {
      logger.e('저장소 접근 권한이 필요합니다: $e');
      try {
        // 앱 전용 경로 가져오기
        final directory = await getDownloadsDirectory();
        final filePath = '${directory!.path}/BookExport.xlsx';

        final uniqueFilePath = getUniqueFilePath(directory.path, 'BookExport.xlsx');
        
        // 파일 저장
        final file = File(uniqueFilePath);
        await file.writeAsBytes(bytes, flush: true);

        logger.d('엑셀 파일이 성공적으로 저장되었습니다: $filePath');
        filedropMessage(filePath);
      } catch (e) {
        logger.e('파일 저장 중 오류 발생: $e');
      }
    }
  }

  void filedropMessage(String filePath) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('파일이 저장되었습니다 \n $filePath', style: const TextStyle(fontSize: 16)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String getUniqueFilePath(String dir, String fileName) {
    File file = File('$dir/$fileName');
    String name = fileName.split('.').first; // "DataGrid"
    String extension = fileName.split('.').last; // "xlsx"
    int counter = 1;

    while (file.existsSync()) {
      file = File('$dir/${name}_($counter).$extension');
      counter++;
    }

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.4*0.3,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0), // 원하는 모양으로 조절
              ),
              backgroundColor: HoloColors.nekomataOkayu
            ),
            onPressed: () async {
              final xls.Workbook workbook = xls.Workbook();

              try {
                // 연월별로 데이터를 그룹화
                final Map<String, List<DataGridRow>> groupedRows = {};
                for (final row in transactionDataSource.rows) {
                  final String? dateValue = row.getCells().firstWhere((cell) => cell.columnName == 'Date').value;
                  if (dateValue == null) continue;

                  final DateTime dateTime = DateFormat("yyyy년 MM월 dd일THH:mm").parse(dateValue);
                  final String yearMonth = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';

                  groupedRows.putIfAbsent(yearMonth, () => []).add(row);
                }

                // 각 연월별로 시트를 생성하여 데이터 추가
                groupedRows.forEach((yearMonth, rows) {
                  final xls.Worksheet worksheet = workbook.worksheets.addWithName(yearMonth);

                  // 특정 행(rows)만 엑셀 시트로 내보내기
                  key.currentState!.exportToExcelWorksheet(
                    worksheet,
                    rows: rows, // 연월별 데이터만 내보냄
                  );
                });
              } catch (e) {
                logger.e(e);
                final xls.Worksheet worksheet = workbook.worksheets[0];
                key.currentState!.exportToExcelWorksheet(worksheet);
              }

              final List<int> bytes = workbook.saveAsStream();
              await exportToExcel(bytes);
              // File('DataGrid.xlsx').writeAsBytes(bytes, flush: true);
            },
            child: const AutoSizeText('데이터 \n다운로드', style: TextStyle(fontSize: 36, color: Colors.white), maxLines: 2),
          ),
        ),
        Offstage(
          child: SfDataGrid(
            key: key,
            source: transactionDataSource,
            columns: <GridColumn>[
              GridColumn(
                columnName: 'Date',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Date')
                )
              ),
              GridColumn(
                columnName: 'Name',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Name')
                )
              ),
              GridColumn(
                columnName: 'Amount',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Amount')
                )
              ),
              GridColumn(
                columnName: 'Category',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Category')
                )
              ),
              GridColumn(
                columnName: 'CategoryType',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('CategoryType')
                )
              ),
              GridColumn(
                columnName: 'Description',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Description')
                )
              ),
              GridColumn(
                columnName: 'Installation',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Installation')
                )
              ),
              GridColumn(
                columnName: 'Credit',
                label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.center,
                  child: const Text('Credit')
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}