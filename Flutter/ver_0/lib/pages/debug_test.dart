import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:excel/excel.dart';

class TestBed extends StatefulWidget {
  const TestBed({super.key});

  @override
  State<TestBed> createState() => _TestBedState();
}

class _TestBedState extends State<TestBed> {
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    try {
      var file = '/data/user/0/com.mugtest.ver_0/cache/file_picker/test.xlsx';
      var bytes = File(file).readAsBytesSync();
      logger.d('${bytes}');
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        logger.d(table); //sheet Name
        logger.d(excel.tables[table]!.maxColumns);
        logger.d(excel.tables[table]!.maxRows);
        for (var row in excel.tables[table]!.rows) {
          for (var cell in row) {
            logger.d('cell ${cell!.rowIndex}/${cell.columnIndex}');
            final value = cell.value;
            final numFormat = cell.cellStyle?.numberFormat ?? NumFormat.standard_0;
            switch(value){
              case null:
                logger.d('  empty cell');
                logger.d('  format: ${numFormat}');
              case TextCellValue():
                logger.d('  text: ${value.value}');
              case FormulaCellValue():
                logger.d('  formula: ${value.formula}');
                logger.d('  format: ${numFormat}');
              case IntCellValue():
                logger.d('  int: ${value.value}');
                logger.d('  format: ${numFormat}');
              case BoolCellValue():
                logger.d('  bool: ${value.value ? 'YES!!' : 'NO..' }');
                logger.d('  format: ${numFormat}');
              case DoubleCellValue():
                logger.d('  double: ${value.value}');
                logger.d('  format: ${numFormat}');
              case DateCellValue():
                logger.d('  date: ${value.year} ${value.month} ${value.day} (${value.asDateTimeLocal()})');
              case TimeCellValue():
                logger.d('  time: ${value.hour} ${value.minute} ... (${value.asDuration()})');
              case DateTimeCellValue():
                logger.d('  date with time: ${value.year} ${value.month} ${value.day} ${value.hour} ... (${value.asDateTimeLocal()})');
            }

            logger.d('$row');
          }
        }
      }
    } catch (e) {
      logger.e('Error in testbed: $e');
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
