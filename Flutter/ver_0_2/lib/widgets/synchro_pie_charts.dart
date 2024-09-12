import 'package:flutter/material.dart';
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
  final Function(ChartPointDetails) onPieSelected;

  const PieChartsByCategoryYear({
    required this.year,
    required this.onPieSelected,
    super.key
  });

  @override
  State<PieChartsByCategoryYear> createState() => _PieChartsByCategoryYearState();
}

class _PieChartsByCategoryYearState extends State<PieChartsByCategoryYear> {
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
    
    List<Map<String, dynamic>> fetchedDatas = await DatabaseAdmin().getYearlySumByCategory(widget.year);
    for (var data in fetchedDatas) {
      totalValue = totalValue + data['totalAmount'];
    }

    for (var data in fetchedDatas) {
      localChartData.add(_PieChartData(data['category'], data['totalAmount'], data['totalAmount']/totalValue*100));
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
      legend: const Legend(isVisible: true, iconWidth: 25, iconHeight: 25),
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
  List<_PieChartData> chartData = [];

  @override
  void initState() {
    super.initState();
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
        legend: const Legend(isVisible: true, iconWidth: 25, iconHeight: 25),
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