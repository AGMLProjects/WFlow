import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/model/GasConsumed.dart';

class GasConsumedChart extends StatelessWidget {
  const GasConsumedChart({super.key, required this.consumes});

  final List<GasConsumed> consumes;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> data = [];
    double i = 0;
    for (GasConsumed day in consumes) {
      data.add(FlSpot(i, day.y));
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
    if (value.toInt() < this.consumes.length) {
      GasConsumed day = this.consumes.elementAt(value.toInt());
      text = Text(day.x, style: style);
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
