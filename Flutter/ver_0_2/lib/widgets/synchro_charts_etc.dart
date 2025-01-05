import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_2/widgets/database_admin.dart';

class LineChartDataDatetime {
  LineChartDataDatetime(this.x, this.y);

  final DateTime x;
  final double? y;
}

class ColumnChartDataDatetime {
  ColumnChartDataDatetime(this.x, this.y);
 
  final DateTime x;
  final double y;
}


///메인 페이지 콤보 그래프(3개월 순수입)
class ComboChartsMainpage extends StatefulWidget {
  final int? range;

  const ComboChartsMainpage({
    this.range,
    super.key
  });

  @override
  State<ComboChartsMainpage> createState() => _ComboChartsMainpageState();
}

class _ComboChartsMainpageState extends State<ComboChartsMainpage> {
  Logger logger = Logger();
  late TooltipBehavior _tooltip;
  late ZoomPanBehavior _zoomPanBehavior;
  List<LineChartDataDatetime> chartData = [];
  List<ColumnChartDataDatetime> columChartData = [];
  double maxYvalue = 100;
  double interval = 100;
  double maxYvalueColumn = 100;
  // double dateinterval = 100;
  DateTime mininumDate = DateTime.utc(DateTime.now().year, DateTime.now().month-6);

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      canShowMarker: false,
      textStyle: const TextStyle(fontSize: 20),
      header: '',
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: widget.range == null,
      zoomMode: ZoomMode.x,
      enablePanning: widget.range == null,
    );
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<LineChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    DateTime? localmininumDate;
    // logger.d(mininumDate);
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getIncomeSumMonthlyByMonth(widget.range)).toList();
    if(fetchedDatas.isNotEmpty) {
      fetchedDatas.sort((prev, next) => prev['yearmonth'].compareTo(next['yearmonth']));
      localmininumDate =DateTime.utc(int.parse(fetchedDatas.first['yearmonth'].substring(0,4)),int.parse(fetchedDatas.first['yearmonth'].substring(6,8)));
      for (var data in fetchedDatas) {
        localChartData.add(LineChartDataDatetime(DateTime.utc(int.parse(data['yearmonth'].substring(0,4)),int.parse(data['yearmonth'].substring(6,8))), data['totalAmount']));
        if (localmaxYvalue < (data['totalAmount']).abs()) {
          localmaxYvalue = (data['totalAmount']).abs();
        }
      }
      if (mounted) {
        setState(() {
          mininumDate = localmininumDate!;
          chartData = localChartData;
          interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/3).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
          maxYvalue = ((localmaxYvalue/interval).ceil()*interval).toDouble();
        });
      }
    }

    List<ColumnChartDataDatetime> localColumnChartData = [];
    double localColumnmaxYvalue = 0;
    List<Map<String, dynamic>> fetchedColumnDatas = (await DatabaseAdmin().getNetIncomeSumMonthlyByMonth(widget.range)).toList();
    if(fetchedColumnDatas.isNotEmpty) {
      fetchedColumnDatas.sort((prev, next) => prev['yearmonth'].compareTo(next['yearmonth']));
      localmininumDate =DateTime.utc(int.parse(fetchedDatas.first['yearmonth'].substring(0,4)),int.parse(fetchedDatas.first['yearmonth'].substring(6,8)));
      for (var data in fetchedColumnDatas) {
        localColumnChartData.add(ColumnChartDataDatetime(DateTime.utc(int.parse(data['yearmonth'].substring(0,4)),int.parse(data['yearmonth'].substring(6,8))), data['totalAmount']));
        if (localColumnmaxYvalue < (data['totalAmount']).abs()) {
          localColumnmaxYvalue = (data['totalAmount']).abs();
        }
      }
      if (mounted) {
        setState(() {
          if(localmininumDate!.isBefore(mininumDate) ) {
            mininumDate = localmininumDate;
          }
          columChartData = localColumnChartData;
          maxYvalueColumn = ((localColumnmaxYvalue/interval).ceil()*interval).toDouble();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
      return SfCartesianChart(
        // title: const ChartTitle(
        //   // text: '${widget.tagName} 월간 양상',
        //   alignment: ChartAlignment.center,
        //   backgroundColor: Colors.white,
        //   borderColor: Colors.transparent,
        //   borderWidth: 10
        // ),
        tooltipBehavior: _tooltip,
        zoomPanBehavior: _zoomPanBehavior,
        primaryXAxis: DateTimeAxis(
          labelRotation: 60,
          dateFormat: DateFormat.yM(),
          intervalType: DateTimeIntervalType.months,
          rangePadding: ChartRangePadding.none,
          maximumLabels: 6,
          desiredIntervals: 6,
          initialVisibleMinimum: widget.range == null ? null : DateTime.utc(DateTime.now().year, DateTime.now().month-6),
          initialVisibleMaximum: DateTime.utc(DateTime.now().year, DateTime.now().month, 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxYvalue,
          interval: interval,
          isVisible: widget.range == null,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),   
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'yAxisSecondary',
            opposedPosition: true,
            interval: maxYvalueColumn*1.2,
            maximum: (maxYvalueColumn).abs()*1.2,
            minimum: (maxYvalueColumn).abs()*-1.2,
            isVisible: widget.range == null,
            numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),  
            // majorGridLines: const MajorGridLines(width: 0),
            // title: AxisTitle(
            //   text: 'Secondary Y Axis'
            // )
          )
        ],
        series: <CartesianSeries>[
          ColumnSeries<ColumnChartDataDatetime, DateTime>(
            pointColorMapper:(ColumnChartDataDatetime data, _){
            if(data.y > 0) {
              return Colors.grey.shade600;
            } else {
              return Colors.red.shade600;
            }
          },
            dataSource: columChartData,
            xValueMapper: (ColumnChartDataDatetime data, _) => data.x,
            yValueMapper: (ColumnChartDataDatetime data, _) => data.y,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,)
            ),
            yAxisName: 'yAxisSecondary'
          ),
          LineSeries<LineChartDataDatetime, DateTime>(
            // name: widget.tagName,
            // animationDuration: 4500,
            dataSource: chartData,
            xValueMapper: (LineChartDataDatetime data, _) => data.x,
            yValueMapper: (LineChartDataDatetime data, _) => data.y,
            markerSettings: const MarkerSettings(isVisible: true, height : 10.0, width : 10.0),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ]
      );
    }
}


class StackChartDataDatetime {
  StackChartDataDatetime(this.x, this.stacklist, this.ylist);

  final DateTime x;
  final List<String>? stacklist;
  final List<double>? ylist;
}


///메인 페이지 스택 그래프(3개월 수입)
class StackChartsMainpage extends StatefulWidget {
  final int? range;
  final Function(ChartPointDetails)? onPieDoubleSelected;

  const StackChartsMainpage({
    this.range,
    this.onPieDoubleSelected,
    super.key
  });

  @override
  State<StackChartsMainpage> createState() => _StackChartsMainpageState();
}

class _StackChartsMainpageState extends State<StackChartsMainpage> {
  Logger logger = Logger();
  late TooltipBehavior _tooltip;
  late ZoomPanBehavior _zoomPanBehavior;
  List<StackChartDataDatetime> chartData = [];
  List<String> categoryList = [];
  double maxYvalue = 100;
  double interval = 100;
  // double dateinterval = 100;
  DateTime mininumDate = DateTime.utc(DateTime.now().year, DateTime.now().month-6);

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      canShowMarker: false,
      textStyle: const TextStyle(fontSize: 20),
      header: '',
    );
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: widget.range == null,
      zoomMode: ZoomMode.x,
      enablePanning: widget.range == null,
    );

    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<StackChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    DateTime? localmininumDate;
    
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getIncomeSumMonthlyByCategory(widget.range)).toList();
    if(fetchedDatas.isNotEmpty) {
      fetchedDatas.sort((prev, next) => prev['yearmonth'].compareTo(next['yearmonth']));
      localmininumDate =DateTime.utc(int.parse(fetchedDatas.first['yearmonth'].substring(0,4)),int.parse(fetchedDatas.first['yearmonth'].substring(6,8)));
      
      Map<String, List<Map<String, dynamic>>> groupedData = groupBy(fetchedDatas, (Map<String, dynamic> item) => item['category']);
      Set<String> uniqueCategories = groupedData.keys.toSet();
      groupedData = groupBy(fetchedDatas, (Map<String, dynamic> item) => item['yearmonth']);
      for (var key in groupedData.keys) {
        List<double> localylist = [];
        List<String> stacklist = [];
        double localamountSum = 0;
        for (var category in uniqueCategories) {
          if (groupedData[key]!.any((item) => item['category'] == category)) {
            var data = groupedData[key]!.firstWhere((item) => item['category'] == category);
            localylist.add(data['totalAmount']);
            localamountSum = localamountSum + data['totalAmount']; 
          } else {
            localylist.add(0);
          }
          stacklist.add(key);
        }
        if (localmaxYvalue < localamountSum) {
          localmaxYvalue = localamountSum;
        }
        localChartData.add(StackChartDataDatetime(DateTime.utc(int.parse(key.substring(0,4)),int.parse(key.substring(6,8)),), stacklist, localylist));
      }
      if (mounted) {
        setState(() {
          mininumDate = localmininumDate!;
          categoryList = uniqueCategories.toList();
          chartData = localChartData;
          interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/3).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
          maxYvalue = ((localmaxYvalue/interval).ceil()*interval).toDouble();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
      return SfCartesianChart(
        title: const ChartTitle(
          // text: '${widget.tagName} 월간 양상',
          alignment: ChartAlignment.center,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          borderWidth: 10
        ),
        tooltipBehavior: _tooltip,
        zoomPanBehavior: _zoomPanBehavior,
        primaryXAxis: DateTimeAxis(
          labelRotation: 60,
          dateFormat: DateFormat.yM(),
          intervalType: DateTimeIntervalType.months,
          rangePadding: ChartRangePadding.none,
          maximumLabels: 6,
          desiredIntervals: 6,
          initialVisibleMinimum: widget.range == null ? null : DateTime.utc(DateTime.now().year, DateTime.now().month-6),
          initialVisibleMaximum: DateTime.utc(DateTime.now().year, DateTime.now().month, 0),
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxYvalue,
          interval: interval,
          isVisible: widget.range == null,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),   
        ),
        series:
        List.generate(
          categoryList.length,
          (i) {
            return StackedAreaSeries<StackChartDataDatetime, DateTime>(
              groupName: categoryList[i],
              dataSource: chartData,
              xValueMapper: (StackChartDataDatetime data, _) => data.x,
              yValueMapper: (StackChartDataDatetime data, _) {
                return data.ylist != null ? data.ylist![i] : 0;
              },
              onPointDoubleTap: widget.onPieDoubleSelected,
              dataLabelSettings: DataLabelSettings(
                labelAlignment: ChartDataLabelAlignment.top,
                useSeriesColor: true,
                isVisible: i == categoryList.length-1,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                showCumulativeValues: true,
              ),
            );
          },
        )
      );
    }
}