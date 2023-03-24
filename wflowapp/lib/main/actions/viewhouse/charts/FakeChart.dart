import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FakeChart extends StatelessWidget {
  const FakeChart({super.key});

  @override
  Widget build(BuildContext context) {
    final _random = new Random();
    final List<FlSpot> data = [];
    for (double i = 0; i < 30; i++) {
      data.add(FlSpot(i, _random.nextInt(20) as double));
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: SingleChildScrollView(
        physics: ScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.all(8),
          width: 900,
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              lineTouchData: LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
