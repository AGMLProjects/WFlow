import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/main/home/HouseWidget.dart';
import 'Indicator.dart';

class WaterPieChart extends StatelessWidget {
  const WaterPieChart({super.key, required this.houseWidgets});

  final List<HouseWidget> houseWidgets;

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];
    List<Widget> indicators = [];

    for (HouseWidget houseWidget in houseWidgets) {
      if (houseWidget.house.house_id != 0) {
        PieChartSectionData sectionData = PieChartSectionData(
            color: houseWidget.house.color,
            value: houseWidget.house.total_liters,
            showTitle: true,
            title: houseWidget.house.total_liters.toString());
        sections.add(sectionData);
      }
    }

    for (HouseWidget houseWidget in houseWidgets) {
      if (houseWidget.house.house_id != 0) {
        Indicator indicator = Indicator(
          color: houseWidget.house.color!,
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
