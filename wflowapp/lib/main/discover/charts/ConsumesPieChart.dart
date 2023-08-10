import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/Indicator.dart';
import 'package:wflowapp/main/discover/model/Consume.dart';
import 'package:wflowapp/main/home/HouseWidget.dart';

class ConsumesPieChart extends StatelessWidget {
  final List<Consume> consumes;

  ConsumesPieChart({super.key, required this.consumes});

  List<Color> colors = [
    Colors.green,
    Colors.lightGreen,
    Colors.greenAccent,
    Colors.cyan,
    Colors.blueAccent,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink
  ];

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];
    List<Widget> indicators = [];

    int i = 0;
    for (Consume consume in consumes) {
      PieChartSectionData sectionData = PieChartSectionData(
          color: colors[i],
          value: consume.consume.toDouble(),
          showTitle: true,
          title: consume.consume.toString());
      sections.add(sectionData);
      i++;
    }

    i = 0;
    for (Consume consume in consumes) {
      Indicator indicator = Indicator(
        color: colors[i],
        text: consume.region,
        isSquare: true,
      );
      indicators.add(indicator);
      i++;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: PieChart(PieChartData(
            sections: sections,
          )),
        ),
        const SizedBox(width: 50),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: indicators)
      ],
    );
  }
}
