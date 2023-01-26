import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/home/ui/HouseWidget.dart';
import 'Indicator.dart';

class WaterPieChart extends StatelessWidget {
  WaterPieChart({super.key, required this.houseWidgets});

  final List<HouseWidget> houseWidgets;

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];
    List<Widget> indicators = [];

    for (HouseWidget houseWidget in houseWidgets) {
      if (!houseWidget.isAdd) {
        PieChartSectionData sectionData = PieChartSectionData(
            color: houseWidget.color,
            value: houseWidget.house.consumes,
            showTitle: true,
            title: houseWidget.house.consumes.toString());
        sections.add(sectionData);
      }
    }

    for (HouseWidget houseWidget in houseWidgets) {
      if (!houseWidget.isAdd) {
        Indicator indicator = Indicator(
          color: houseWidget.color,
          text: houseWidget.house.name,
          isSquare: true,
        );
        indicators.add(indicator);
      }
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
        SizedBox(width: 50),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: indicators)
      ],
    );
  }
}
