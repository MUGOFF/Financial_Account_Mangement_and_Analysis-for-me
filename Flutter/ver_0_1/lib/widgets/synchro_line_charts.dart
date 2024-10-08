import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_1/widgets/database_admin.dart';


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
      canShowMarker: false,
      textStyle: const TextStyle(fontSize: 20),
    );
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<LineChartDataDatetime> localChartData = [];
    double localmaxYvalue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = await DatabaseAdmin().getCategorySumByYear(widget.category);
    for (var data in fetchedDatas) {
      localChartData.add(LineChartDataDatetime(DateTime.utc(int.parse(data['year'])), data['totalAmount']));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
    }

    if (mounted) {
      setState(() {
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
              isVisible: false,
              labelIntersectAction: LabelIntersectAction.shift,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
          )
        ]
      );
    }
}