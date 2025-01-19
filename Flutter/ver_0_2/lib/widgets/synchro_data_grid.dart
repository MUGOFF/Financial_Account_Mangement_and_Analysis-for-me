// import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';
import 'package:ver_0_2/widgets/models/extra_budget_group.dart';

class TransactionGridDataSource extends DataGridSource {
  final List<MoneyTransaction> transanctions;
  TransactionGridDataSource({required this.transanctions}) {
    // tagTransactionPage = transanctions.length < _rowsPerPage
    //   ? transanctions
    //   : transanctions.getRange(0, _rowsPerPage).toList();
    buildPaginatedDataGridRows();
    // dataGridRows = transanctions
    //     .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
    //           DataGridCell<String>(columnName: 'Date', value: dataGridRow.transactionTime),
    //           DataGridCell<String>(columnName: 'Name', value: dataGridRow.goods),
    //           DataGridCell<double>(columnName: 'Amount', value: dataGridRow.amount),
    //           DataGridCell<String>(columnName: 'Category', value: dataGridRow.category),
    //         ]))
    //     .toList();
  }
  // List<MoneyTransaction> tagTransactionPage=[];
  // final int _rowsPerPage = 5;

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

  // @override
  // Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
  //   int startIndex = newPageIndex * _rowsPerPage;
  //   int endIndex = startIndex + _rowsPerPage;
  //   if (startIndex < transanctions.length && endIndex <= transanctions.length) {
  //     tagTransactionPage =
  //         transanctions.getRange(startIndex, endIndex).toList(growable: false);
  //     buildPaginatedDataGridRows();
  //     notifyListeners();
  //   } else {
  //     tagTransactionPage = [];
  //   }
  //   logger.d('index move $tagTransactionPage');
  //   return true;
  // }

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
    // this.afterEdit,
    required this.context,
  }) {
    // if (extraTransaction.length < _rowsPerPage){
    //   extraTransactionPage = extraTransaction;
    // } else {
    //   extraTransactionPage = extraTransaction.getRange(0, _rowsPerPage).toList();
    // }
    extraTransactionPage = extraTransaction.length < _rowsPerPage
      ? extraTransaction
      : extraTransaction.getRange(0, _rowsPerPage).toList();
    buildPaginatedDataGridRows();
    // dataGridRows = extraTransaction
    //   .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
    //     // DataGridCell<String>(columnName: 'id', value: dataGridRow.dataid),
    //     DataGridCell<String>(columnName: 'name', value: dataGridRow.name),
    //     DataGridCell<String>(
    //         columnName: 'category', value: dataGridRow.category),
    //     DataGridCell<int>(
    //         columnName: 'amount', value: dataGridRow.amount),
    //     DataGridCell<Function>(
    //         columnName: 'modify', value: dataGridRow.modifyCategory),
    //   ]))
    //   .toList();
    // logger.d(dataGridRows);
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
      // DataGridRow(cells: [
      //   DataGridCell(columnName: 'orderID', value: dataGridRow.orderID),
      //   DataGridCell(columnName: 'customerID', value: dataGridRow.customerID),
      //   DataGridCell(columnName: 'orderDate', value: dataGridRow.orderDate),
      //   DataGridCell(columnName: 'freight', value: dataGridRow.freight),
      // ]);
    }).toList(growable: false);
    // logger.i(dataGridRows);
  }
  // void updateDataToDatabase(String jsonData, int dataID) {
  //   DatabaseAdmin().updateExtraJsonData(jsonData, dataID);
  // }
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
  // void fetchTableData() {
  //   _tableRawData.asMap().forEach((index, rows) {
  //     // logger.d(_tableRawData);
  //     //_tableData에서 _tableRawData에 포함되지 않은 dataid를 가진 항목을 제거
  //     tableData.removeWhere((row) => !_tableRawData.any((rawRow) => rawRow['dataid'] == row.dataid));
  //     if (tableData.isEmpty || !(tableData.any((tableRow) => tableRow.dataid == rows['dataid']))) {
  //       selectedTransactionData.add(rows['id']);
  //       tableData.add(ExtraTransactionGrid(
  //         dataid: rows['dataid'],
  //         name: rows['goods'],
  //         category: rows['category'],
  //         amount: rows['amount'],
  //         modifyCategory: (String category) {
  //           setState(() {
  //             _tableRawData[index]['category'] = category;
  //             updateCategoryDataToDatabase(_tableRawData,widget.id);
  //             fetchBaseDatas();
  //             widget.updatePageCallback();
  //           });
  //           // logger.i(_tableRawData);
  //         },
  //       ));
  //     }
  //   });
  //   setState(() {
  //     _tableDataSource = ExtraTransactionSource(
  //       extraTransaction: tableData,
  //       context: context
  //     );
  //   });
  // }
  
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
