import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/model/WeeklyConsume.dart';

class LitersConsumesBarChart extends StatefulWidget {
  const LitersConsumesBarChart({super.key, required this.consumes});

  final List<WeeklyConsume> consumes;

  @override
  _LitersConsumesBarChartState createState() =>
      _LitersConsumesBarChartState(consumes: consumes);
}

class _LitersConsumesBarChartState extends State<LitersConsumesBarChart> {
  _LitersConsumesBarChartState({required this.consumes});

  final List<WeeklyConsume> consumes;
  late int showingTooltip;

  @override
  void initState() {
    showingTooltip = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<BarChartGroupData> items = [];
    double maxY = 0;
    for (int i = 0; i < 7; i++) {
      double avg = consumes.elementAt(i).avg;
      double current = consumes.elementAt(i).current;
      items.add(makeBarGroups(i, avg, current));
      if (avg > maxY) {
        maxY = avg;
      }
      if (current > maxY) {
        maxY = current;
      }
    }

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: BarChart(
        BarChartData(
          barGroups: items,
          maxY: maxY + 3,
          barTouchData: barTouchData(),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: bottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: leftTitles(),
            ),
          ),
          borderData: FlBorderData(
              border: const Border(
            left: BorderSide(),
            bottom: BorderSide(),
          )),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData makeBarGroups(int x, double avg, double current) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: avg,
          color: Colors.orange,
          width: 12,
        ),
        BarChartRodData(
          toY: current,
          color: Colors.cyan,
          width: 12,
        ),
      ],
    );
  }

  BarTouchData barTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.blueGrey,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          Color color;
          if (rodIndex % 2 == 0) {
            color = Colors.orange;
          } else {
            color = Colors.cyan;
          }
          return BarTooltipItem(
            '${rod.toY - 1} L',
            TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          );
        },
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

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 12, //margin top
      child: text,
    );
  }
}
