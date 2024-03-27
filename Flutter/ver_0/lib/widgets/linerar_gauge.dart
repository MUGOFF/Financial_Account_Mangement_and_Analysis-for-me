import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class PercentageGaugeBar extends StatefulWidget {
  final double childNumber;
  final double motherNumber;
  final bool isThick;
  PercentageGaugeBar({required this.childNumber, required this.motherNumber, this.isThick=true, super.key});

  final normalColor = Colors.green.shade800;
  final warningColor = Colors.yellow.shade800;
  final dangerColor = Colors.red.shade800;

  @override
  State<PercentageGaugeBar> createState() => _PercentageGaugeBarState();
}

class _PercentageGaugeBarState extends State<PercentageGaugeBar> {
  
  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final double percentageValue = 
      widget.motherNumber == 0 ? 100 : 
      // widget.childNumber/widget.motherNumber*100 >= 100 ? 100 : 
      widget.childNumber/widget.motherNumber*100;
    return Stack(
      children: [
        SfLinearGauge(
          showTicks: false,
          showLabels: false,
          animateAxis: true,
          axisTrackStyle: LinearAxisTrackStyle(
            thickness: widget.isThick ? 50 : 30,
            edgeStyle: LinearEdgeStyle.bothCurve,
            borderWidth: 1,
            borderColor: brightness == Brightness.dark
                ? const Color(0xff898989)
                : Colors.grey.shade400,
            color: brightness == Brightness.dark
                ? Colors.transparent
                : Colors.grey.shade400,
          ),
          barPointers: <LinearBarPointer>[
            LinearBarPointer(
              value: percentageValue,
              thickness: widget.isThick ? 50 : 30,
              edgeStyle: LinearEdgeStyle.bothCurve,
              color: widget.motherNumber == 0 ? widget.warningColor : percentageValue >= 100? widget.dangerColor : widget.normalColor
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: widget.isThick ? 10 : 2),
          child: Align(
            alignment: const Alignment(0.5,1),
            child: Text(
              '${percentageValue.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 18, color: Color(0xffFFFFFF)),
            )
          ),
        ),
      ],
    );
  }
}