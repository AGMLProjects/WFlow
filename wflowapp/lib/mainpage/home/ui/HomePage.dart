import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/home/ui/HouseWidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static List<Widget> _houses = [
    HouseWidget(title: 'Main house'),
    HouseWidget(title: 'Mountain house'),
    HouseWidget()
  ];
  static List<PieChartSectionData> _pieChart = [
    PieChartSectionData(color: Colors.red),
    PieChartSectionData(color: Colors.blue)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0,
                    color: Colors.blue),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12.0)),
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 20.0,
                ),
              )
            ],
          ),
          SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'My houses 🏡',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          CarouselSlider(
              items: _houses,
              options: CarouselOptions(
                  height: 170.0,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  enlargeCenterPage: true)),
          SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'My total consumes 💧',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.black),
              ),
              //PieChart(PieChartData(sections: _pieChart)),
            ],
          ),
          SizedBox(height: 32.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Expected total cost 💸',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                    color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
