import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_2/widgets/database_admin.dart';


// 가  계  부 그  래  프 //
Logger logger = Logger();

///차트 데이터 기본클래스 생성
class _BarChartData {
  _BarChartData(this.x, this.y, this.label);
 
  final String x;
  final double y;
  final String label;
}

///월간 카테고리별 소비(비교)
class ColumnChartsByCategoryMonth extends StatefulWidget {
  final int year;
  final int month;
  final int pastyear;
  final int pastmonth;
  final Function(ChartPointDetails) onBarSelected;

  ColumnChartsByCategoryMonth({
    required this.year,
    required this.month,
    required this.pastyear,
    required this.pastmonth,
    required this.onBarSelected,
    super.key
  });

  final Color presentBarColor = Colors.teal.shade400;
  final Color pastBarColor = Colors.grey.shade400;
  final Color overflowColor = Colors.red.shade600;

  @override
  State<ColumnChartsByCategoryMonth> createState() => _ColumnChartsByCategoryMonthState();
}

class _ColumnChartsByCategoryMonthState extends State<ColumnChartsByCategoryMonth> {
  Logger logger = Logger();
  late TooltipBehavior _tooltip;
  List<_BarChartData> chartData = [];
  List<_BarChartData> charPastData = [];
  double maxYvalue = 100;
  double interval = 100;

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<_BarChartData> localChartData = [];
    List<_BarChartData> localPastChartData = [];
    double localmaxYvalue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.year,widget.month)).toList();

    fetchedDatas.sort((prev, next) => next['totalAmount'].compareTo(prev['totalAmount']));
    
    var limitedFetchedDatas = fetchedDatas.take(5);
    var categories = limitedFetchedDatas.map((data) => data['category']).toSet();

    for (var data in limitedFetchedDatas) {
      localChartData.add(_BarChartData(data['category'], data['totalAmount'] < 0 ? data['totalAmount']*-0.25: data['totalAmount'], NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(data['totalAmount']).toString()));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
      if (localmaxYvalue < data['totalAmount']*-0.25) {
        localmaxYvalue = data['totalAmount']*-0.25;
      }
    }

    List<Map<String, dynamic>> fetchedPastDatas = (await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.pastyear,widget.pastmonth)).toList();

    var limitedFetchedPastDatas = fetchedPastDatas.where((data) => categories.contains(data['category'])).toList();
    for (var data in limitedFetchedPastDatas) {
      localPastChartData.add(_BarChartData(data['category'], data['totalAmount'] < 0 ? data['totalAmount']*-0.25: data['totalAmount'], NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(data['totalAmount']).toString()));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
      if (localmaxYvalue < data['totalAmount']*-0.25) {
        localmaxYvalue = data['totalAmount']*-0.25;
      }
    }
    if (mounted) {
      setState(() {
        chartData = localChartData;
        charPastData = localPastChartData;
        interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/3).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
        maxYvalue = ((localmaxYvalue/interval).ceil()*interval).toDouble();
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return  SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: maxYvalue,
        interval: interval,
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),
      ),
      tooltipBehavior: _tooltip,
      series: <CartesianSeries<_BarChartData, String>>[
        ColumnSeries<_BarChartData, String>(
            width: 0.3,
            spacing : 0.1,
            dataSource: chartData,
            xValueMapper: (_BarChartData chartData, _) => chartData.x,
            yValueMapper: (_BarChartData chartData, _) => chartData.y,
            dataLabelMapper: (_BarChartData chartData, _) => chartData.label,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
            onPointTap: widget.onBarSelected,
            name: 'Present',
            color: widget.presentBarColor
        ),
        ColumnSeries<_BarChartData, String>(
            width: 0.3,
            spacing : 0.1,
            dataSource: charPastData,
            xValueMapper: (_BarChartData charPastData, _) => charPastData.x,
            yValueMapper: (_BarChartData charPastData, _) => charPastData.y,
            dataLabelMapper: (_BarChartData charPastData, _) => charPastData.label,
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
            name: 'Past',
            color: widget.pastBarColor
            
        ),
      ]
    );
  }
}

///카테고리 세부 내역 바차트
class BarchartGoodsInCategories extends StatefulWidget {
  final int year;
  final int month;
  final String category;
  const BarchartGoodsInCategories({required this.year, required this.month, required this.category, super.key});

  @override
  State<BarchartGoodsInCategories> createState() => _BarchartGoodsInCategoriesState();
}

class _BarchartGoodsInCategoriesState extends State<BarchartGoodsInCategories> {
  Logger logger = Logger();
  List<_BarChartData> chartData = [];
  double maxYvalue = 100;
  double interval = 100;
  final TooltipBehavior _tooltip= TooltipBehavior(
    enable: true,
    // shouldAlwaysShow: true,
    header: "",
    borderWidth: 5,
    textStyle: const TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
    tooltipPosition: TooltipPosition.pointer,
    format: 'point.x',
  );
 
  @override
  void initState() {
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<_BarChartData> localChartData = [];
    double localmaxYvalue = 0;
    List<Map<String, dynamic>> fetchedDatas = await DatabaseAdmin().getransactionsSUMBByGoodsCategoriesMonth(widget.year,widget.month,widget.category);
    var limitedFetchedDatas = fetchedDatas.take(15);
    for (var data in limitedFetchedDatas) {
      localChartData.add(_BarChartData(data['goods'], data['totalAmount'], data['totalAmount'].toString()));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
    }
    if (mounted) {
      setState(() {
        chartData = localChartData;
        maxYvalue = max(localmaxYvalue*1.1,1);
        interval = localmaxYvalue == 0 ? 1 : max(pow(10, (log((localmaxYvalue/2).abs())/ln10).floor()).toDouble(),pow(10, (log((localmaxYvalue).abs())/ln10).floor()).toDouble()/2);
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(
        text: '${widget.year}-${widget.month.toString().padLeft(2, '0')} ${widget.category} 항목 상위 15개',
        alignment: ChartAlignment.center,
        backgroundColor: Colors.white,
        borderColor: Colors.transparent,
        borderWidth: 10
      ),
      primaryXAxis: const CategoryAxis(
        labelPosition: ChartDataLabelPosition.inside,
        // labelRotation: 45,
        labelStyle: TextStyle(
          fontSize: 16,
          color: Color.fromRGBO(250, 250, 250, 0.4),
          overflow: TextOverflow.ellipsis
        )
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: maxYvalue,
        interval: interval,
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR"),      
      ),
      tooltipBehavior: _tooltip,
      series: <CartesianSeries<_BarChartData, String>>[
        BarSeries<_BarChartData, String>(
          width: 0.8,
          dataSource: chartData,
          xValueMapper: (_BarChartData chartData, _) => chartData.x,
          yValueMapper: (_BarChartData chartData, _) => chartData.y,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(50)),
          sortFieldValueMapper: (_BarChartData chartData, _) => chartData.y,
          sortingOrder: SortingOrder.ascending,
          name: widget.category,
          color: Colors.teal.shade200,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.outer,
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)
          )
        )
      ]
    );
  }
}