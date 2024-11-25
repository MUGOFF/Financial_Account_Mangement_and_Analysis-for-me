// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/widgets/models/money_transaction.dart';

class TransactionGridDataSource extends DataGridSource {
  TransactionGridDataSource({required List<MoneyTransaction> transanctions}) {
    dataGridRows = transanctions
        .map<DataGridRow>((dataGridRow) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'Date', value: dataGridRow.transactionTime),
              DataGridCell<String>(columnName: 'Name', value: dataGridRow.goods),
              DataGridCell<double>(columnName: 'Amount', value: dataGridRow.amount),
              DataGridCell<String>(columnName: 'Category', value: dataGridRow.category),
            ]))
        .toList();
  }

  List<DataGridRow> dataGridRows = [];

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

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          // constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5,),
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
          // child: (dataGridCell.columnName == 'Date')
          //   ? AutoSizeText(formatterDate(dataGridCell.value), maxLines: 1)
          //   : Text(
          //   (dataGridCell.columnName == 'Amount')
          //   ?formatterK(dataGridCell.value)
          //   : dataGridCell.value.toString(),
          //   overflow: (dataGridCell.columnName == 'Name')
          //     ? TextOverflow.ellipsis
          //     : TextOverflow.clip,
          //   // style:  TextStyle(fontSize: (dataGridCell.columnName == 'Date')
          //   //   ? 12
          //   //   : 16
          //   // ),
          )
        );
    }).toList());
  }

  // @override
  // Future<void> handleLoadMoreRows() async {
  //   await Future.delayed(const Duration(seconds: 3));
  //   // _addMoreRows(transanctions, 15);
  //   notifyListeners();
  // }

  // void _addMoreRows(List<MoneyTransaction> transanctions, int count) {
  //   final Random _random = Random();
  //   final startIndex = transanctions.isNotEmpty ? transanctions.length : 0,
  //       endIndex = startIndex + count;
  //   for (int i = startIndex; i < endIndex; i++) {
  //     transanctions.add(MoneyTransaction(
  //       1000 + i,
  //       _names[_random.nextInt(_names.length - 1)],
  //       _designation[_random.nextInt(_designation.length - 1)],
  //       10000 + _random.nextInt(10000),
  //     ));
  //   }
  // }
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
    return Column(
      children: [
        Expanded(
          child: SfDataGrid(
            source: tagTransactionDataSource!,
            columnWidthMode: ColumnWidthMode.fill,
            allowSorting: true,
            // allowMultiColumnSorting: true,
            allowTriStateSorting: true,
            // allowFiltering: true,
            // columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
            // loadMoreViewBuilder: (BuildContext context, LoadMoreRows loadMoreRows) {
            // Future<String> loadRows() async {
            //   // Call the loadMoreRows function to call the
            //   // DataGridSource.handleLoadMoreRows method. So, additional
            //   // rows can be added from handleLoadMoreRows method.
            //   await loadMoreRows();
            //   return Future<String>.value('Completed');
            // }

            //   return FutureBuilder<String>(
            //     initialData: 'loading',
            //     future: loadRows(),
            //     builder: (context, snapShot) {
            //       if (snapShot.data == 'loading') {
            //         return Container(
            //           height: 60.0,
            //           width: double.infinity,
            //           decoration: const BoxDecoration(
            //             color: Colors.white,
            //             border: BorderDirectional(top: BorderSide(width: 1.0,color: Color.fromRGBO(0, 0, 0, 0.26)))
            //           ),
            //           alignment: Alignment.center,
            //           child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.deepPurple))
            //         );
            //       } else {
            //         return SizedBox.fromSize(size: Size.zero);
            //       }
            //     }
            //   );
            // },
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
      ]
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       Expanded(
  //         child: SfDataGrid(
  //           source: tagTransactionDataSource!,
  //           columnWidthMode: ColumnWidthMode.fill,
  //           allowSorting: true,
  //           // allowMultiColumnSorting: true,
  //           allowTriStateSorting: true,
  //           // allowFiltering: true,
  //           // columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
  //           columns: [
  //             GridColumn(
  //               // allowFiltering: false,
  //               columnName: 'Date',
  //               label: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 alignment: Alignment.center,
  //                 child: const Text('Date')
  //               )
  //             ),
  //             GridColumn(
  //               // allowFiltering: false,
  //               columnName: 'Name',
  //               label: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 alignment: Alignment.center,
  //                 child: const Text('Name')
  //               )
  //             ),
  //             GridColumn(
  //               // allowFiltering: false,
  //               columnName: 'Amount',
  //               label: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 alignment: Alignment.center,
  //                 child: const Text('Amount')
  //               )
  //             ),
  //             GridColumn(
  //               allowSorting: false,
  //               // filterPopupMenuOptions: const FilterPopupMenuOptions(canShowSortingOptions: false, filterMode:FilterMode.checkboxFilter,canShowClearFilterOption: false),
  //               columnName: 'Category',
  //               label: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 alignment: Alignment.center,
  //                 child: const Text('Category')
  //               )
  //             ),
  //           ],
  //         ),
  //       ),
  //     ]
  //   );
  // }
}

