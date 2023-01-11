import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/home/ui/HouseWidget.dart';
import 'Indicator.dart';

class WaterPieChart extends StatelessWidget {
  WaterPieChart({super.key, required this.houses});

  final List<HouseWidget> houses;

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> _sections = [
      PieChartSectionData(
          color: houses.elementAt(0).color,
          value: 75,
          showTitle: true,
          title: '75%'),
      PieChartSectionData(
          color: houses.elementAt(1).color,
          value: 25,
          showTitle: true,
          title: '25%'),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: PieChart(PieChartData(
            sections: _sections,
          )),
        ),
        SizedBox(width: 50),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Indicator(
            color: houses.elementAt(0).color,
            text: houses.elementAt(0).title,
            isSquare: true,
          ),
          Indicator(
            color: houses.elementAt(1).color,
            text: houses.elementAt(1).title,
            isSquare: true,
          ),
        ])
      ],
    );
  }
}
