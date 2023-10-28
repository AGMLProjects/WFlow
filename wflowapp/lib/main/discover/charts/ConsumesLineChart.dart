import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/discover/model/Consume.dart';

class ConsumesLineChart extends StatelessWidget {
  const ConsumesLineChart(
      {super.key, required this.consumes1, required this.consumes2});

  final List<Consume> consumes1;
  final List<Consume> consumes2;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> data1 = [];
    final List<FlSpot> data2 = [];
    dynamic minY = double.maxFinite;
    dynamic maxY = 0;
    for (int i = 0; i < 6; i++) {
      data1.add(FlSpot(i.toDouble(), consumes1[i].consume.toDouble()));
      if (consumes1[i].consume.toDouble() > maxY) {
        maxY = consumes1[i].consume.toDouble();
      }
      if (consumes1[i].consume.toDouble() < minY) {
        minY = consumes1[i].consume.toDouble();
      }
      data2.add(FlSpot(i.toDouble(), consumes2[i].consume.toDouble()));
      if (consumes2[i].consume.toDouble() > maxY) {
        maxY = consumes2[i].consume.toDouble();
      }
      if (consumes2[i].consume.toDouble() < minY) {
        minY = consumes2[i].consume.toDouble();
      }
    }

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: LineChart(
        LineChartData(
          minY: minY - 20,
          maxY: maxY + 20,
          titlesData: titlesData(),
          borderData: FlBorderData(
              border: const Border(
            left: BorderSide(),
            bottom: BorderSide(),
          )),
          gridData: FlGridData(
            drawHorizontalLine: false,
          ),
          lineBarsData: [
            LineChartBarData(
              color: Colors.cyan,
              spots: data1,
              isCurved: true,
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: dots1,
              ),
            ),
            LineChartBarData(
              color: Colors.grey,
              spots: data2,
              isCurved: true,
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: dots2,
              ),
            )
          ],
        ),
      ),
    );
  }

  FlDotPainter dots1(spot, percent, barData, index) {
    return FlDotCirclePainter(radius: 4, color: Colors.cyan);
  }

  FlDotPainter dots2(spot, percent, barData, index) {
    return FlDotCirclePainter(radius: 4, color: Colors.grey);
  }

  FlTitlesData titlesData() {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: leftTitles(),
      ),
      bottomTitles: AxisTitles(
        sideTitles: bottomTitles(),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  SideTitles leftTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: 20,
      getTitlesWidget: leftTitleWidgets,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 10,
    );

    Widget text = Text(value.round().toString(), style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  SideTitles bottomTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: 1,
      getTitlesWidget: bottomTitleWidgets,
    );
  }

  Widget bottomTitleWidgets(dynamic value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 10,
    );
    Widget text;
    if (value.toInt() < consumes1.length) {
      int year = consumes1[value.toInt()].year;
      int month = consumes1[value.toInt()].month;
      String monthStr = month.toString().padLeft(2, '0');
      String yearStr = year.toString();
      String date = "${monthStr}/${yearStr.substring(2)}";
      text = Text(date, style: style);
    } else {
      text = const Text('', style: style);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 12,
      child: text,
    );
  }
}
