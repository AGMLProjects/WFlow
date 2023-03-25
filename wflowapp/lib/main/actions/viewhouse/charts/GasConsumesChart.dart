import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/viewhouse/model/GasConsumed.dart';

class GasConsumesChart extends StatelessWidget {
  const GasConsumesChart({super.key, required this.consumes});

  final List<GasConsumed> consumes;

  @override
  Widget build(BuildContext context) {
    // TODO: replace this
    final _random = new Random();
    final List<FlSpot> data = [];
    double maxY = 0;
    for (double i = 0; i < 30; i++) {
      double random = _random.nextInt(20) as double;
      data.add(FlSpot(i, random));
      if (random > maxY) {
        maxY = random;
      }
    }

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY + 3,
          lineTouchData: lineTouchData(),
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
              spots: data,
              isCurved: true,
              barWidth: 1.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: dots,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FlDotPainter dots(spot, percent, barData, index) {
    bool predicted = consumes.elementAt(index).predicted;
    Color color;
    if (predicted == false) {
      color = AppConfig.getDefaultColor();
    } else {
      color = Colors.grey;
    }

    return FlDotCirclePainter(radius: 4, color: color);
  }

  LineTouchData lineTouchData() {
    return LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData:
            LineTouchTooltipData(getTooltipItems: tooltipWidgets));
  }

  List<LineTooltipItem> tooltipWidgets(List<LineBarSpot> lineBarsSpot) {
    return lineBarsSpot.map((lineBarSpot) {
      return LineTooltipItem(
        "${lineBarSpot.y} L\n${consumes.elementAt(lineBarSpot.x as int).x}",
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
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
      interval: 3,
      getTitlesWidget: leftTitleWidgets,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 10,
    );
    Widget text = Text(value.toString(), style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  SideTitles bottomTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: 5,
      getTitlesWidget: bottomTitleWidgets,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 12,
    );
    Widget text;
    if (value.toInt() < this.consumes.length) {
      GasConsumed day = this.consumes.elementAt(value.toInt());
      String date = day.x.split("/")[0] + "/" + day.x.split("/")[1];
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
