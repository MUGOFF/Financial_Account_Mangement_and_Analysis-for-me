import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_2/colorsholo.dart';
import 'package:ver_0_2/widgets/database_admin.dart';


class LineChartData {
  LineChartData(this.x, this.y);
  
  final int x;
  final double? y;
}
class LineChartDataDatetime {
  LineChartDataDatetime(this.x, this.y);

  final DateTime x;
  final double? y;
}

///연별 카테고리 내역 소비변화
class LineChartsByYearCategory extends StatefulWidget {
  final int year;
  final String category;

  const LineChartsByYearCategory({
    required this.year,
    required this.category,
    super.key
  });

  @override
  State<LineChartsByYearCategory> createState() => _LineChartsByYearCategoryState();
}

class _LineChartsByYearCategoryState extends State<LineChartsByYearCategory> {
  Logger logger = Logger();
  late TooltipBehavior _tooltip;
  List<LineChartDataDatetime> chartData = [];
  double maxYvalue = 100;
  double interval = 100;

  @override
  void initState() {
    _tooltip = TooltipBehavior(
      enable: true,
      header: "",
      // canShowMarker: false,
      textStyle: const TextStyle(fontSize: 20),
      format: 'point.x',
    );
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<LineChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = await DatabaseAdmin().getCategorySumByYear(widget.category);
    for (var data in fetchedDatas) {
      localChartData.add(LineChartDataDatetime(DateTime(int.parse(data['year'])), data['totalAmount']));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
    }

    if (mounted) {
      setState(() {
        chartData = localChartData;
        interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/3).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
        maxYvalue = ((localmaxYvalue/interval).ceil()*interval).toDouble()+(localmaxYvalue*0.01).ceil();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return SfCartesianChart(
        title: ChartTitle(
          text: '연간 ${widget.category}',
          alignment: ChartAlignment.center,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          borderWidth: 10
        ),
        tooltipBehavior: _tooltip,
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.y(),
          rangePadding: ChartRangePadding.round,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxYvalue,
          interval: interval,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),      
        ),
        series: <CartesianSeries>[
          SplineSeries<LineChartDataDatetime, DateTime>(
            name: widget.category,
            dataSource: chartData,
            xValueMapper: (LineChartDataDatetime data, _) => data.x,
            yValueMapper: (LineChartDataDatetime data, _) => data.y,
            markerSettings: const MarkerSettings(isVisible: true, height : 16.0, width : 16.0),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              // labelIntersectAction: LabelIntersectAction.shift,
              labelAlignment: ChartDataLabelAlignment.top,
              // labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
          )
        ]
      );
    }
}


///태그 월간 사용 그래프
class LineChartsByYearMonthTag extends StatefulWidget {
  final String tagName;

  const LineChartsByYearMonthTag({
    required this.tagName,
    super.key
  });

  @override
  State<LineChartsByYearMonthTag> createState() => _LineChartsByYearMonthTagState();
}

class _LineChartsByYearMonthTagState extends State<LineChartsByYearMonthTag> {
  Logger logger = Logger();
  TrackballBehavior _trackballBehavior = TrackballBehavior(enable: true,);
  List<LineChartDataDatetime> chartData = [];
  double maxYvalue = 100;
  double interval = 100;
  // double dateinterval = 100;
  DateTime? mininumDate;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        format: 'point.x : \n point.y',
        color: HoloColors.takanashiKiara,
        textStyle: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
      )
    );
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<LineChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getTagSumByYearMonth(widget.tagName)).toList();

    fetchedDatas.sort((prev, next) => prev['yearmonth'].compareTo(next['yearmonth']));
    // fetchedDatas.sort((prev, next) => next['yearmonth'].compareTo(prev['yearmonth']));
    // logger.i(fetchedDatas);
    mininumDate =DateTime(int.parse(fetchedDatas.first['yearmonth'].substring(0,4)),int.parse(fetchedDatas.first['yearmonth'].substring(6,8)));
    for (var data in fetchedDatas) {
      localChartData.add(LineChartDataDatetime(DateTime(int.parse(data['yearmonth'].substring(0,4)),int.parse(data['yearmonth'].substring(6,8))), data['totalAmount']));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
    }
    // double localdateinterval = (localChartData.length/5);
    if (mounted) {
      setState(() {
        // dateinterval = localdateinterval;
        // logger.i(dateinterval);
        chartData = localChartData;
        interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/3).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
        maxYvalue = ((localmaxYvalue/interval).ceil()*interval).toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return SfCartesianChart(
        title: ChartTitle(
          text: '${widget.tagName} 월간 양상',
          alignment: ChartAlignment.center,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          borderWidth: 10
        ),
        trackballBehavior: _trackballBehavior,
        primaryXAxis: DateTimeAxis(
          labelRotation: 60,
          dateFormat: DateFormat.yM(),
          intervalType: DateTimeIntervalType.months,
          // interval: dateinterval,
          rangePadding: ChartRangePadding.none,
          maximumLabels: 8,
          desiredIntervals: 8,
          minimum: mininumDate,
        ),
        primaryYAxis: NumericAxis(
          minimum: 0,
          maximum: maxYvalue,
          interval: interval,
          numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),
        ),
        series: <CartesianSeries>[
          SplineSeries<LineChartDataDatetime, DateTime>(
            name: widget.tagName,
            color: HoloColors.takanashiKiara,
            splineType: SplineType.monotonic,
            dataSource: chartData,
            xValueMapper: (LineChartDataDatetime data, _) => data.x,
            yValueMapper: (LineChartDataDatetime data, _) => data.y,
            // markerSettings: const MarkerSettings(isVisible: true, height : 8.0, width : 8.0),
            dataLabelSettings: const DataLabelSettings(isVisible: false),
          )
        ]
      );
    }
}
