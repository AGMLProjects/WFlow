import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/home/rest/MonthExpense.dart';
import 'package:wflowapp/mainpage/home/ui/HouseWidget.dart';
import '../../rest/House.dart';
import 'Indicator.dart';

class CostLineChart extends StatelessWidget {
  CostLineChart({super.key, required this.months});

  final List<MonthExpense> months;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> data = [];
    double i = 0;
    for (MonthExpense month in months) {
      data.add(FlSpot(i, month.total));
      i++;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 260,
      child: LineChart(
        LineChartData(
            //lineTouchData: lineTouchData(),
            titlesData: titlesData(),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 10,
            lineBarsData: [
              LineChartBarData(
                  spots: data, isCurved: true, isStepLineChart: false)
            ]),
      ),
    );
  }

  LineTouchData lineTouchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
    );
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
      reservedSize: 40,
      interval: 10,
      getTitlesWidget: leftTitleWidgets,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 12,
    );
    Widget text = Text(value.toString(), style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 15,
      child: text,
    );
  }

  SideTitles bottomTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 50,
      interval: 1,
      getTitlesWidget: bottomTitleWidgets,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 12,
    );
    Widget text;
    if (value.toInt() < this.months.length) {
      MonthExpense month = this.months.elementAt(value.toInt());
      text = Text(month.parseDate(), style: style);
    } else {
      text = const Text('', style: style);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 15,
      child: text,
    );
  }
}
