import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/mainpage/home/rest/HomePageClient.dart';
import 'package:wflowapp/mainpage/home/rest/HousesResponse.dart';
import 'package:wflowapp/mainpage/home/ui/HouseWidget.dart';
import 'package:wflowapp/mainpage/home/ui/WaterPieChart.dart';

import '../rest/House.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<House> _houses = [];
  List<HouseWidget> _houseWidgets = [];

  final HomePageClient client = const HomePageClient(
      url: 'https://49c13ba9-40e6-426b-be3c-21acf8b4f1d4.mock.pstmn.io',
      path: '/houses');

  Future<HousesResponse>? _futureHousesResponse;

  @override
  Widget build(BuildContext context) {
    setState(() {
      _futureHousesResponse = client.getHouses("AAAA");
    });

    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(
      title: Text('Dashboard'),
      actions: <Widget>[
        Container(
          padding: EdgeInsets.all(16.0),
          child: Icon(
            Icons.notifications,
            color: Colors.white,
            size: 20.0,
          ),
        )
      ],
    );
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  drawHousesTitle(),
                  SizedBox(height: 16.0),
                  buildHousesCarousel(),
                  SizedBox(height: 32.0),
                  drawConsumesTitle(),
                  SizedBox(height: 24.0),
                  Text(
                    '124L',
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20.0,
                        color: Colors.black),
                  ),
                  SizedBox(height: 24.0),
                  buildWaterPieChart(),
                  SizedBox(height: 32.0),
                  /*             
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
                    SizedBox(height: 300.0),
                    Text('data'), 
                    */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget drawHousesTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'My houses 🏡',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
        ),
      ],
    );
  }

  Widget drawConsumesTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'My total consumes 💧',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
        )
      ],
    );
  }

  FutureBuilder<HousesResponse> buildHousesCarousel() {
    return FutureBuilder<HousesResponse>(
      future: _futureHousesResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return SizedBox.shrink();
          }
          for (House house in snapshot.data!.houses) {
            _houseWidgets.add(HouseWidget(
              house: house,
              isAdd: false,
            ));
          }
          _houseWidgets.add(HouseWidget(
            house: House(name: ''),
            isAdd: true,
          ));
          log('Found ' + (_houseWidgets.length - 1).toString() + ' house(s)');
          return CarouselSlider(
              items: _houseWidgets,
              options: CarouselOptions(
                  height: 170.0,
                  enableInfiniteScroll: false,
                  autoPlay: false,
                  enlargeCenterPage: true));
        } else if (snapshot.hasError) {
          return SizedBox.shrink();
        }
        return const CircularProgressIndicator();
      },
    );
  }

  FutureBuilder<HousesResponse> buildWaterPieChart() {
    return FutureBuilder<HousesResponse>(
      future: _futureHousesResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return SizedBox.shrink();
          }
          if (_houseWidgets.isEmpty) {
            for (House house in snapshot.data!.houses) {
              _houseWidgets.add(HouseWidget(
                house: house,
                isAdd: false,
              ));
            }
          }
          return WaterPieChart(
            houseWidgets: _houseWidgets,
          );
        } else if (snapshot.hasError) {
          return SizedBox.shrink();
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
