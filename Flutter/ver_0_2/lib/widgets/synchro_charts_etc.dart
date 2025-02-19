import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_2/widgets/database_admin.dart';
import 'package:ver_0_2/colorsholo.dart';

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
  bool isloading = false;
  late TooltipBehavior _tooltip;
  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior();
  List<LineChartDataDatetime> chartData = [];
  List<ColumnChartDataDatetime> columChartData = [];
  double maxYvalue = 100;
  double interval = 100;
  double maxYvalueColumn = 100;
  double maxZooming  = 0.5;
  DateTime mininumDate = DateTime(DateTime.now().year, DateTime.now().month-6);

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      canShowMarker: false,
      textStyle: const TextStyle(fontSize: 20),
      header: '',
    );
    _fetchChartDatas().then((_) {
        try {
          _zoomPanBehavior = ZoomPanBehavior(
          enablePinching: widget.range == null,
          zoomMode: ZoomMode.x,
          maximumZoomLevel: maxZooming,
          enablePanning: widget.range == null,
       );
        } catch (e) {
          _zoomPanBehavior = ZoomPanBehavior(
            enablePinching: widget.range == null,
            zoomMode: ZoomMode.x,
            maximumZoomLevel: maxZooming,
            enablePanning: widget.range == null,
          );
        }
    });
    super.initState();
  }

  Future<void> _fetchChartDatas() async {
    if(widget.range == null) {
      isloading = true;
    }
    List<LineChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    double chartStackYvalue = 0;
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getNetIncomeSumMonthlyByMonth(widget.range)).toList();
    int numOfData = fetchedDatas.length;
    if(fetchedDatas.isNotEmpty) {
      fetchedDatas.sort((prev, next) => prev['yearmonth'].compareTo(next['yearmonth']));
      for (var data in fetchedDatas) {
        chartStackYvalue = chartStackYvalue + data['totalAmount'];
        localChartData.add(LineChartDataDatetime(DateFormat('yyyy년 MM월').parse(data['yearmonth']), chartStackYvalue));
        if (localmaxYvalue < (chartStackYvalue).abs()) {
          localmaxYvalue = (chartStackYvalue).abs();
        }
      }
      if (mounted) {
        setState(() {
          isloading = false;
          chartData = localChartData;
          maxZooming = 3/numOfData > 1 ? 1 : 3/numOfData;
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
      for (var data in fetchedColumnDatas) {
        localColumnChartData.add(ColumnChartDataDatetime(DateFormat('yyyy년 MM월').parse(data['yearmonth']), data['totalAmount']));
        if (localColumnmaxYvalue < (data['totalAmount']).abs()) {
          localColumnmaxYvalue = (data['totalAmount']).abs();
        }
      }
      if (mounted) {
        setState(() {
          columChartData = localColumnChartData;
          maxYvalueColumn = ((localColumnmaxYvalue/interval).ceil()*interval).toDouble();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      double zoomfactorCal = 6/chartData.length > 1 ? 1 : 6/chartData.length;
      List<LineChartDataDatetime> pastTiemData =
        chartData.where((dataPoint) => dataPoint.x.isBefore(DateTime(DateTime.now().year,DateTime.now().month))).toList();

      // 마지막 구간 데이터 필터링
      List<LineChartDataDatetime> futureTiemData =
          chartData.where((dataPoint) => dataPoint.x.isAfter(DateTime(DateTime.now().year,DateTime.now().month-2))).toList();
      return SfCartesianChart(
        title: ChartTitle(
          text: widget.range != null ?'' : '월간 순수입과 누적 그래프',
          alignment: ChartAlignment.center,
          // borderColor: Colors.transparent,
          // borderWidth: 10
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
          initialZoomFactor: widget.range != null ? 1 : zoomfactorCal,
          initialZoomPosition: 1,
        ),
        primaryYAxis: NumericAxis(
          maximum: maxYvalue,
          interval: interval,
          isVisible: widget.range == null,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),   
        ),
        axes: <ChartAxis>[
          NumericAxis(
            name: 'yAxisSecondary',
            opposedPosition: true,
            interval: maxYvalueColumn*1.1,
            maximum: (maxYvalueColumn).abs()*1.1,
            minimum: (maxYvalueColumn).abs()*-1.1,
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
              if(data.x.isAfter(DateTime(DateTime.now().year,DateTime.now().month-1))) {
                return Colors.black.withOpacity(0.5);
              } else{
                return Colors.black;
              }
            } else {
              if(data.x.isAfter(DateTime(DateTime.now().year,DateTime.now().month-1))) {
                return Colors.red.withOpacity(0.5);
              } else{
                return Colors.red;
              }
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
            dataSource: pastTiemData,
            color: HoloColors.ceresFauna,
            xValueMapper: (LineChartDataDatetime data, _) => data.x,
            yValueMapper: (LineChartDataDatetime data, _) => data.y,
            markerSettings: const MarkerSettings(isVisible: true, height : 10.0, width : 10.0),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
          LineSeries<LineChartDataDatetime, DateTime>(
            dataSource: futureTiemData,
            color: HoloColors.ceresFauna,
            dashArray: const <double>[5, 5],
            xValueMapper: (LineChartDataDatetime data, _) => data.x,
            yValueMapper: (LineChartDataDatetime data, _) => data.y,
            markerSettings: const MarkerSettings(isVisible: true, height : 10.0, width : 10.0),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          ),
        ]
      );
    }
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
  bool isloading = false;
  // late TooltipBehavior _tooltip;
  ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior();
  TrackballBehavior _trackballBehavior = TrackballBehavior(enable: true,);
  List<StackChartDataDatetime> chartData = [];
  List<String> categoryList = [];
  double maxYvalue = 100;
  double interval = 100;
  double maxZooming  = 0.5;
  DateTime mininumDate = DateTime(DateTime.now().year, DateTime.now().month-6);

  @override
  void initState() {
    // _tooltip = TooltipBehavior(
    //   enable: true,
    //   canShowMarker: false,
    //   textStyle: const TextStyle(fontSize: 20),
    //   header: '',
    // );
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        // format: 'point.name : \n point.y',
        color: HoloColors.otonoseKanade,
        textStyle: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
      )
    );
    super.initState();
    _fetchChartDatas().then((_) {
        try {
          _zoomPanBehavior = ZoomPanBehavior(
          enablePinching: widget.range == null,
          zoomMode: ZoomMode.x,
          maximumZoomLevel: maxZooming,
          enablePanning: widget.range == null,
       );
        } catch (e) {
          _zoomPanBehavior = ZoomPanBehavior(
            enablePinching: widget.range == null,
            zoomMode: ZoomMode.x,
            maximumZoomLevel: maxZooming,
            enablePanning: widget.range == null,
          );
        }
    });
  }

  Future<void> _fetchChartDatas() async {
    if(widget.range == null) {
      isloading = true;
    }
    List<StackChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    DateTime? localmininumDate;
    int numOfData = 1;

    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getIncomeSumMonthlyByCategory(widget.range)).toList();
    if(fetchedDatas.isNotEmpty) {
      fetchedDatas.sort((prev, next) => prev['yearmonth'].compareTo(next['yearmonth']));
      localmininumDate =DateTime(int.parse(fetchedDatas.first['yearmonth'].substring(0,4)),int.parse(fetchedDatas.first['yearmonth'].substring(6,8)));
      
      Map<String, List<Map<String, dynamic>>> groupedData = groupBy(fetchedDatas, (Map<String, dynamic> item) => item['category']);
      Set<String> uniqueCategories = groupedData.keys.toSet();
      groupedData = groupBy(fetchedDatas, (Map<String, dynamic> item) => item['yearmonth']);
      numOfData = groupedData.length;
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
        localChartData.add(StackChartDataDatetime(DateTime(int.parse(key.substring(0,4)),int.parse(key.substring(6,8)),), stacklist, localylist));
      }
      if (mounted) {
        setState(() {
          isloading = false;
          mininumDate = localmininumDate!;
          categoryList = uniqueCategories.toList();
          chartData = localChartData;
          maxZooming = 3/numOfData > 1 ? 1 : 3/numOfData;
          interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/3).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
          maxYvalue = ((localmaxYvalue/interval).ceil()*interval).toDouble();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      double zoomfactorCal = 6/chartData.length > 1 ? 1 : 6/chartData.length;
      return SfCartesianChart(
        // tooltipBehavior: _tooltip,
        zoomPanBehavior: _zoomPanBehavior,
        trackballBehavior: _trackballBehavior,
        title: const ChartTitle(
          // text: '${widget.tagName} 월간 양상',
          alignment: ChartAlignment.center,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          borderWidth: 10
        ),
        primaryXAxis: DateTimeAxis(
          labelRotation: 60,
          dateFormat: DateFormat.yM(),
          intervalType: DateTimeIntervalType.months,
          rangePadding: ChartRangePadding.none,
          maximumLabels: 6,
          desiredIntervals: 6,
          initialZoomFactor: widget.range != null ? 1 : zoomfactorCal,
          initialZoomPosition: 1,
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
              name: categoryList[i],
              onPointDoubleTap: widget.onPieDoubleSelected,
              dataLabelSettings: DataLabelSettings(
                labelAlignment: ChartDataLabelAlignment.top,
                useSeriesColor: true,
                isVisible: i == categoryList.length-1,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                showCumulativeValues: true,
              ),
              dataLabelMapper: (StackChartDataDatetime data, _) => data.ylist![i] == data.ylist!.max ? data.ylist![i].toString() : '',
            );
          },
        )
      );
    }
  }
}

class BubbleChartData {
  BubbleChartData(this.name, this.x, this.y, this.size);

  final String name;
  final double x;
  final double y;
  final double size;
}

///메인 페이지 버블블
class BubbleMainpage extends StatefulWidget {
  final List<String> nameList;
  final List<double>? valueList;

  const BubbleMainpage({
    required this.nameList,
    this.valueList,
    super.key
  });

  @override
  State<BubbleMainpage> createState() => _BubbleMainpageState();
}

class _BubbleMainpageState extends State<BubbleMainpage> {
  Logger logger = Logger();
  bool isloading = false;
  List<BubbleChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchChartDatas();
  }

  void _fetchChartDatas() {
    if (widget.valueList == null) {
      if (widget.nameList.isEmpty) {
        return;
      } else if (widget.nameList.length == 1) {
        chartData.add(BubbleChartData(widget.nameList[0], 5, 5, 100));
      } else if (widget.nameList.length == 2) {
        chartData.add(BubbleChartData(widget.nameList[0], 10, 10, 100));
        chartData.add(BubbleChartData(widget.nameList[1], 1, 1, 50));
      } else if (widget.nameList.length == 3) {
        chartData.add(BubbleChartData(widget.nameList[0], 7, 7, 100));
        chartData.add(BubbleChartData(widget.nameList[1], 2, 4, 50));
        chartData.add(BubbleChartData(widget.nameList[2], 6, 2, 25));
      }
    } else {
      if (widget.nameList.isEmpty) {
        return;
      } else if (widget.nameList.length == 1) {
        chartData.add(BubbleChartData(widget.nameList[0], 5, 5, widget.valueList![0]));
      } else if (widget.nameList.length == 2) {
        chartData.add(BubbleChartData(widget.nameList[0], 10, 10, widget.valueList![0]));
        chartData.add(BubbleChartData(widget.nameList[1], 1, 1, widget.valueList![1]));
      } else if (widget.nameList.length == 3) {
        chartData.add(BubbleChartData(widget.nameList[0], 7, 7, widget.valueList![0]));
        chartData.add(BubbleChartData(widget.nameList[1], 3, 4, widget.valueList![1]));
        chartData.add(BubbleChartData(widget.nameList[2], 6, 2, widget.valueList![2]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isloading) {
      return const Center(child: CircularProgressIndicator());
    } else if(widget.nameList.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),));
    } else {
      return SfCartesianChart(
        plotAreaBorderWidth : 0,
        title: const ChartTitle(
          alignment: ChartAlignment.center,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          borderWidth: 10
        ),
        primaryXAxis: const NumericAxis(
          minimum: 0,
          maximum: 10,
          isVisible: false  
        ),
        primaryYAxis: const NumericAxis(
          minimum: 0,
          maximum: 10,
          isVisible: false  
        ),
        series:<CartesianSeries>[
            // Renders bubble chart
            BubbleSeries<BubbleChartData, num>(
                dataSource: chartData,
                minimumRadius: 10,
                maximumRadius: 30,
                sizeValueMapper: (BubbleChartData data, _) => data.size,
                xValueMapper: (BubbleChartData data, _) => data.x,
                yValueMapper: (BubbleChartData data, _) => data.y,
                pointColorMapper: (datum, index) => [HoloColors.ookamiMio, HoloColors.ceresFauna, HoloColors.hoshimachiSuisei][index], 
                dataLabelMapper: (BubbleChartData data, _) => '${data.name}\n${data.size.toStringAsFixed(2)}',
                dataLabelSettings : const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  labelAlignment: ChartDataLabelAlignment.middle
                )
            )
        ]
      );
    }
  }
}