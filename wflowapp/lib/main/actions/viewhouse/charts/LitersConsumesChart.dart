import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/Consume.dart';
import 'package:wflowapp/main/actions/viewhouse/model/DayConsume.dart';

class LitersConsumesChart extends StatelessWidget {
  LitersConsumesChart({super.key, required this.real, required this.predicted});

  List<DayConsume> real;
  List<DayConsume> predicted;

  List<Consume> consumes = [];

  @override
  Widget build(BuildContext context) {
    int i = 0;
    for (int j = 0; j < real.length; j++, i++) {
      consumes.add(Consume(
          x: i,
          y: real[j].total_water_liters,
          day: real[j].date,
          predicted: false));
    }
    for (int j = 0; j < predicted.length; j++, i++) {
      consumes.add(Consume(
          x: i,
          y: predicted[j].total_water_liters,
          day: predicted[j].date,
          predicted: true));
    }

    final List<FlSpot> data = [];
    double maxY = 0.0;
    for (int i = 0; i < consumes.length; i++) {
      data.add(FlSpot(i.toDouble(), consumes[i].y.toDouble()));
      if (consumes[i].y > maxY) {
        maxY = consumes[i].y;
      }
    }

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY + 3.0,
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
      color = Colors.cyan;
    } else {
      color = const Color.fromARGB(200, 195, 195, 195);
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
      Color color;
      if (consumes[lineBarSpot.x.round()].predicted) {
        color = Colors.white;
      } else {
        color = Colors.cyan;
      }
      return LineTooltipItem(
        "${lineBarSpot.y.toStringAsFixed(2)} L",
        TextStyle(
          color: color,
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
      interval: 5,
      getTitlesWidget: bottomTitleWidgets,
    );
  }

  Widget bottomTitleWidgets(dynamic value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 12,
    );
    Widget text;
    if (value.toInt() < consumes.length) {
      Consume day = consumes[value.toInt()];
      String date = "${day.day.split("-")[2]}/${day.day.split("-")[1]}";
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
