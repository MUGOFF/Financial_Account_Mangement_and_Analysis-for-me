import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ver_0/widgets/database_admin.dart';

class BarChartSample2 extends StatefulWidget {
  BarChartSample2({super.key});
  final Color leftBarColor = Colors.yellow;
  final Color rightBarColor = Colors.red;
  final Color avgColor = Colors.orange.shade200;
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    // final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      // barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }
  
  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
        ),
        BarChartRodData(
          toY: y2,
          color: widget.rightBarColor,
          width: width,
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(
                  width: 38,
                ),
                const Text(
                  'Transactions',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  'state',
                  style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              height: 38,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: 20,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      getTooltipItem: (a, b, c, d) => null,
                    ),
                    touchCallback: (FlTouchEvent event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                        });
                        return;
                      }

                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                          return;
                        }
                        showingBarGroups = List.of(rawBarGroups);
                        if (touchedGroupIndex != -1) {
                          var sum = 0.0;
                          for (final rod
                              in showingBarGroups[touchedGroupIndex].barRods) {
                            sum += rod.toY;
                          }
                          final avg = sum /
                              showingBarGroups[touchedGroupIndex]
                                  .barRods
                                  .length;

                          showingBarGroups[touchedGroupIndex] =
                              showingBarGroups[touchedGroupIndex].copyWith(
                            barRods: showingBarGroups[touchedGroupIndex]
                                .barRods
                                .map((rod) {
                              return rod.copyWith(
                                  toY: avg, color: widget.avgColor);
                            }).toList(),
                          );
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingBarGroups,
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    if (value == 0) {
      text = '1K';
    } else if (value == 10) {
      text = '5K';
    } else if (value == 19) {
      text = '10K';
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = ['Mn', 'Te', 'Wd', 'Tu', 'Fr', 'St', 'Su'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        // color: Color(0xff7589a2),
        color: Colors.blue,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.black.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.black.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.black.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.red.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.red.withOpacity(0.4),
        ),
      ],
    );
  }
}


// 가  계  부 그  래  프 //


///차트 데이터 기본클래스 생성
class _BarChartData {
  _BarChartData(this.x, this.y);
 
  final String x;
  final double y;
}

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
    
    List<Map<String, dynamic>> fetchedDatas = await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.year,widget.month);
    for (var data in fetchedDatas) {
      localChartData.add(_BarChartData(data['category'], data['totalAmount']));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
      }
    }

    List<Map<String, dynamic>> fetchedPastDatas = await DatabaseAdmin().getTransactionsSUMByCategoryandDate(widget.pastyear,widget.pastmonth);
    for (var data in fetchedPastDatas) {
      localPastChartData.add(_BarChartData(data['category'], data['totalAmount']));
      if (localmaxYvalue < data['totalAmount']) {
        localmaxYvalue = data['totalAmount'];
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

///두가지 비용 데이터 바차트 비교 //////
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
    textStyle: const TextStyle(fontSize: 20),
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
    for (var data in fetchedDatas) {
      localChartData.add(_BarChartData(data['goods'], data['totalAmount']));
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
        text: '${widget.year}-${widget.month.toString().padLeft(2, '0')} ${widget.category} 항목',
        alignment: ChartAlignment.center,
        backgroundColor: Colors.white,
        borderColor: Colors.transparent,
        borderWidth: 10
      ),
      primaryXAxis: const CategoryAxis(),
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
        )
      ]
    );
  }
}