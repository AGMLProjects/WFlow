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
      height: 300,
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
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
      ),
    );
  }

  FlTitlesData titlesData() {
    return FlTitlesData(
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
      getTitlesWidget: leftTitleWidgets,
      showTitles: true,
      interval: 1,
      reservedSize: 40,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff75729e),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '1m';
        break;
      case 2:
        text = '2m';
        break;
      case 3:
        text = '3m';
        break;
      case 4:
        text = '5m';
        break;
      case 5:
        text = '6m';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles bottomTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: 1,
      getTitlesWidget: bottomTitleWidgets,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff72719b),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('SEPT', style: style);
        break;
      case 7:
        text = const Text('OCT', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('');
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
