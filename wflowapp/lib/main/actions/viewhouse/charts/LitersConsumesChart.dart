import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';

class LitersConsumesChart extends StatelessWidget {
  const LitersConsumesChart({super.key, required this.consumes});

  final List<LitersConsumed> consumes;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> data = [];
    double i = 0;
    double maxY = 0;
    for (LitersConsumed day in consumes) {
      data.add(FlSpot(i, day.y));
      i++;
      if (day.y > maxY) {
        maxY = day.y;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      width: 1000,
      height: 260,
      child: LineChart(
        LineChartData(
            //lineTouchData: lineTouchData(),
            titlesData: titlesData(),
            borderData: FlBorderData(show: false),
            minY: 0,
            maxY: maxY + 2,
            minX: 0,
            maxX: 32,
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
      interval: 5,
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
      space: 12,
      child: text,
    );
  }

  SideTitles bottomTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 50,
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
      LitersConsumed day = this.consumes.elementAt(value.toInt());
      text = Text(day.x, style: style);
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
