import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0_2/widgets/database_admin.dart';



class _PieChartData {
    _PieChartData(this.x, this.y, this.yp);

    final String x;
    final double y;
    final double yp;
}

///연간 카테고리별 소비
class PieChartsByCategoryYear extends StatefulWidget {
  final int year;
  // final Function(ChartPointDetails) onPieMonoSelected;
  final Function(ChartPointDetails) onPieDoubleSelected;

  const PieChartsByCategoryYear({
    required this.year,
    // required this.onPieMonoSelected,
    required this.onPieDoubleSelected,
    super.key
  });

  @override
  State<PieChartsByCategoryYear> createState() => _PieChartsByCategoryYearState();
}

class _PieChartsByCategoryYearState extends State<PieChartsByCategoryYear> {
  Logger logger = Logger();
  List<_PieChartData> chartData = [];
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(
      enable: true,
      // shouldAlwaysShow: true,
      header: "",
      borderWidth: 5,
      textStyle: const TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
      tooltipPosition: TooltipPosition.pointer,
      // format: 'point.y',
      builder: (dynamic data, dynamic point, dynamic series,
      int pointIndex, int seriesIndex) {
        return  Container(
          padding: const EdgeInsets.all(7),
          child: Text(NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(data.y), style: const TextStyle(color: Colors.white, fontSize: 24)),
        );
      }
    );
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<_PieChartData> localChartData = [];
    double totalValue = 0;
    double limitedtotalValue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getYearlySumByCategoryNegative(widget.year)).toList();
    fetchedDatas.sort((prev, next) => next['totalAmount'].compareTo(prev['totalAmount']));
    for (var data in fetchedDatas) {
      totalValue = totalValue + data['totalAmount'];
    }

    var limitedFetchedDatas = fetchedDatas.take(5);
    for (var data in limitedFetchedDatas) {
      limitedtotalValue = limitedtotalValue + data['totalAmount'];
    }
    for (var data in limitedFetchedDatas) {
      localChartData.add(_PieChartData(data['category'], data['totalAmount'], data['totalAmount']/totalValue*100));
    }

    double etcValue = totalValue - limitedtotalValue;
    localChartData.add(_PieChartData('etc', etcValue, etcValue/totalValue*100));

    if (mounted) {
      setState(() {
        chartData = localChartData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(isVisible: true, iconWidth: 25, iconHeight: 25, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: _tooltip,
      series: <CircularSeries>[
        PieSeries<_PieChartData, String>(
          dataSource: chartData,
          pointColorMapper:(_PieChartData data, _){
            if(data.x == 'etc') {
              return Colors.grey.shade600;
            } else {
              int code = data.x.hashCode.abs();
              return Color.fromARGB(
                255, // 알파 값 (255는 완전 불투명)
                code % 256, // 빨강 값
                (code ~/ 255) % 256, // 초록 값
                ((code - 255) ~/ (256*3)) % 256, // 파랑 값
              );
            }
          },
          xValueMapper: (_PieChartData data, _) => data.x,
          yValueMapper: (_PieChartData data, _) => data.y,
          dataLabelMapper: (_PieChartData data, _) => '${data.yp.toStringAsFixed(2)}%',
          // onPointTap: widget.onPieMonoSelected,
          onPointDoubleTap: widget.onPieDoubleSelected,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelIntersectAction: LabelIntersectAction.shift,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
          ),
        )
      ]
    );
  }
}

///월간 카테고리별 소비
/// - year: 연도
/// - month: 월
class PieChartsByCategoryMonth extends StatefulWidget {
  final int year;
  final int month;
  final Function(ChartPointDetails) onPieSelected;

  const PieChartsByCategoryMonth({
    required this.year,
    required this.month,
    required this.onPieSelected,
    super.key
  });

  @override
  State<PieChartsByCategoryMonth> createState() => _PieChartsByCategoryMonthState();
}

class _PieChartsByCategoryMonthState extends State<PieChartsByCategoryMonth> {
  Logger logger = Logger();
  List<_PieChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<_PieChartData> localChartData = [];
    double totalValue = 0;
    double limitedtotalValue = 0;
    
    List<Map<String, dynamic>> fetchedDatas = (await DatabaseAdmin().getTransactionsSUMByCategoryMonthNegative(widget.year,widget.month)).toList();

    fetchedDatas.sort((prev, next) => next['totalAmount'].compareTo(prev['totalAmount']));
    
    for (var data in fetchedDatas) {
      totalValue = totalValue + data['totalAmount'];
    }

    // var limitedFetchedDatas = fetchedDatas.take(5);
    // for (var data in limitedFetchedDatas) {
    //   localChartData.add(_PieChartData(data['category'], data['totalAmount'], data['totalAmount']/totalValue*100));
    // }

    var limitedFetchedDatas = fetchedDatas.take(5);
    for (var data in limitedFetchedDatas) {
      limitedtotalValue = limitedtotalValue + data['totalAmount'];
    }
    for (var data in limitedFetchedDatas) {
      localChartData.add(_PieChartData(data['category'], data['totalAmount'], data['totalAmount']/totalValue*100));
    }

    double etcValue = totalValue - limitedtotalValue;
    localChartData.add(_PieChartData('etc', etcValue, etcValue/totalValue*100));


    if (mounted) {
      setState(() {
        chartData = localChartData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(isVisible: true, iconWidth: 25, iconHeight: 25, overflowMode: LegendItemOverflowMode.wrap),
      series: <CircularSeries>[
        PieSeries<_PieChartData, String>(
          dataSource: chartData,
          pointColorMapper:(_PieChartData data, _){
            int code = data.x.hashCode.abs();
            return Color.fromARGB(
              255, // 알파 값 (255는 완전 불투명)
              code % 256, // 빨강 값
              (code ~/ 255) % 256, // 초록 값
              ((code - 255) ~/ (256*3)) % 256, // 파랑 값
            );
          },
          xValueMapper: (_PieChartData data, _) => data.x,
          yValueMapper: (_PieChartData data, _) => data.y,
          dataLabelMapper: (_PieChartData data, _) => '${data.yp.toStringAsFixed(2)}%',
          onPointTap: widget.onPieSelected,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelIntersectAction: LabelIntersectAction.shift,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
          ),
        )
      ]
    );
  }
}

/// 특별 예산 원원그래프
class PieChartByExtraBudget extends StatefulWidget {
  final List<Map<String, double>> dataMap;

  const PieChartByExtraBudget({
    required this.dataMap,
    super.key
  });

  @override
  State<PieChartByExtraBudget> createState() => _PieChartByExtraBudgetState();
}

class _PieChartByExtraBudgetState extends State<PieChartByExtraBudget> {
  Logger logger = Logger();
  late TooltipBehavior _tooltip;
  List<_PieChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(
      enable: true,
      // shouldAlwaysShow: true,
      header: "",
      borderWidth: 5,
      textStyle: const TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
      tooltipPosition: TooltipPosition.pointer,
      // format: 'point.y',
      builder: (dynamic data, dynamic point, dynamic series,
      int pointIndex, int seriesIndex) {
        return  Container(
          padding: const EdgeInsets.all(7),
          child: Text('${data.x}: ${NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(data.y*-1)}', style: const TextStyle(color: Colors.white, fontSize: 24)),
        );
      }
    );
    _fetchChartDatas();
  }

  void _fetchChartDatas(){
    List<_PieChartData> localChartData = [];
    double totalValue = 0;
    
    for (var data in widget.dataMap) {
      totalValue = totalValue + data.values.first;
    }

     for (var data in widget.dataMap) {
      localChartData.add(_PieChartData(data.keys.first, data.values.first, data.values.first/totalValue*100));
    }

    if (mounted) {
      setState(() {
        chartData = localChartData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return SfCircularChart(
        legend: const Legend(isVisible: true, iconWidth: 25, iconHeight: 25, overflowMode: LegendItemOverflowMode.wrap),
        tooltipBehavior: _tooltip,
        series: <CircularSeries>[
          PieSeries<_PieChartData, String>(
            dataSource: chartData,
            pointColorMapper:(_PieChartData data, _) {
              int code = data.x.hashCode.abs();
              return Color.fromARGB(
                255, // 알파 값 (255는 완전 불투명)
                code % 256, // 빨강 값
                (code ~/ 255) % 256, // 초록 값
                ((code - 255) ~/ (256*3)) % 256, // 파랑 값
              );
            },
            xValueMapper: (_PieChartData data, _) => data.x,
            yValueMapper: (_PieChartData data, _) => data.y,
            dataLabelMapper: (_PieChartData data, _) => '${data.yp.toStringAsFixed(2)}%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelIntersectAction: LabelIntersectAction.shift,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
          )
        ]
      );
    }
}


/// 메인페이지 예산산그래프
class BudgetMainPagePieChart extends StatefulWidget {

  const BudgetMainPagePieChart({
    super.key
  });

  @override
  State<BudgetMainPagePieChart> createState() => _BudgetMainPagePieChartState();
}

class _BudgetMainPagePieChartState extends State<BudgetMainPagePieChart> {
  Logger logger = Logger();
  late TooltipBehavior _tooltip;
  List<_PieChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _tooltip = TooltipBehavior(
      enable: true,
      // shouldAlwaysShow: true,
      header: "",
      borderWidth: 5,
      textStyle: const TextStyle(fontSize: 20, overflow: TextOverflow.ellipsis),
      tooltipPosition: TooltipPosition.pointer,
      // format: 'point.y',
      builder: (dynamic data, dynamic point, dynamic series,
      int pointIndex, int seriesIndex) {
        return  Container(
          padding: const EdgeInsets.all(7),
          child: Text('${data.x}: ${NumberFormat.simpleCurrency(decimalDigits: 0, locale: "ko-KR").format(data.y*-1)}', style: const TextStyle(color: Colors.white, fontSize: 24)),
        );
      }
    );
    _fetchChartDatas();
  }

  Future<void> _fetchChartDatas() async {
    List<_PieChartData> localChartData = [];
    double totalValue = 0;
    List<Map<String, dynamic>> fetchedExpenseData =  await DatabaseAdmin().getTransactionsSUMByCategoryandDate(DateTime.now().year,DateTime.now().month);
    List<Map<String, dynamic>> fetchedIncomeData =  await DatabaseAdmin().getTransactionsIncomeSumByMonth(DateTime.now().year,DateTime.now().month);
    List<Map<String, dynamic>> localexpenseData = [...fetchedExpenseData];
    Map<String, dynamic> localIncomeData = await DatabaseAdmin().getIncome();
    localexpenseData.sort((previous, next) => next['totalAmount'].compareTo(previous['totalAmount']));
    double income = 0;
    for (var data in localexpenseData) {
      totalValue = totalValue + data['totalAmount'].abs();
    }
    if(fetchedIncomeData.isNotEmpty) {
      income = fetchedIncomeData.first['totalAmount'];
    } else {
      income = localIncomeData['income'].toDouble();
    }
    // logger.d('income: $income totalValue: $totalValue');
    if (income > totalValue) {
      localChartData.add(_PieChartData('소비', totalValue, totalValue/income*100));
      localChartData.add(_PieChartData('잔금', (income-totalValue)*-1, (income-totalValue)/income*100));
    } else {
      localChartData.add(_PieChartData('소비', totalValue, 100));
    }

    if (mounted) {
      setState(() {
        chartData = localChartData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      return SfCircularChart(
        // legend: const Legend(isVisible: true, iconWidth: 25, iconHeight: 25, overflowMode: LegendItemOverflowMode.wrap),
        tooltipBehavior: _tooltip,
        series: <CircularSeries>[
          PieSeries<_PieChartData, String>(
            dataSource: chartData,
            pointColorMapper:(_PieChartData data, _) {
              return data.yp < 50 
                ? Colors.green 
                : data.yp < 75
                ? Colors.yellow 
                : Colors.red;
            },
            xValueMapper: (_PieChartData data, _) => data.x,
            yValueMapper: (_PieChartData data, _) => data.y,
            dataLabelMapper: (_PieChartData data, _) => '${data.yp.toStringAsFixed(2)}%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelIntersectAction: LabelIntersectAction.shift,
              labelPosition: ChartDataLabelPosition.inside,
              textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
          )
        ]
      );
    }
}