import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/home/HouseWidget.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/WaterPieChart.dart';
import 'package:wflowapp/main/home/client/ExpensesClient.dart';
import 'package:wflowapp/main/home/client/ExpensesResponse.dart';
import 'package:wflowapp/main/home/client/HousesClient.dart';
import 'package:wflowapp/main/home/client/HousesResponse.dart';
import 'package:wflowapp/main/home/client/MonthExpense.dart';
import 'package:wflowapp/main/home/model/House.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<HouseWidget> _houseWidgets = [];
  final List<MonthExpense> _monthExpenses = [];

  final HousesClient housesClient = HousesClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getHousesListPath());

  final ExpensesClient expensesClient =
      ExpensesClient(url: AppConfig.getBaseUrl(), path: '/expenses');

  Future<HousesResponse>? _futureHousesResponse;
  Future<ExpensesResponse>? _futureExpensesResponse;

  @override
  void initState() {
    super.initState();
    String? key = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Read user key from config: ${key!}');
    _futureHousesResponse = housesClient.getHouses(key);
    //_futureExpensesResponse = expensesClient.getExpenses(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Dashboard'),
      actions: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: const Icon(
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                buildHousesCarousel(),
                //const SizedBox(height: 32.0),
                //buildWaterPieChart(),
                //const SizedBox(height: 32.0),
                //buildExpensesLineChart(),
                //const SizedBox(height: 32.0),
              ],
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
        const Text(
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
        const Text(
          'My total consumes 💧',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black),
        )
      ],
    );
  }

  Widget drawExpensesTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Expected total cost 💸',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.black),
        ),
      ],
    );
  }

  FutureBuilder<HousesResponse> buildHousesCarousel() {
    return FutureBuilder<HousesResponse>(
      future: _futureHousesResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          for (House house in snapshot.data!.houses) {
            log(name: 'DEBUG', 'Found "${house.name}" (ID: ${house.house_id})');
            Color? color = AppConfig.getHouseColor(house.house_id);
            color ??= AppConfig.getDefaultColor();
            AppConfig.setHouseColor(house.house_id, color);
            house.color = color;
            _houseWidgets.add(HouseWidget(house: house));
          }
          _houseWidgets.add(HouseWidget(house: House(house_id: 0, name: '')));
          return Column(
            children: [
              CarouselSlider(
                  items: _houseWidgets,
                  options: CarouselOptions(
                      height: 500.0,
                      clipBehavior: Clip.none,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      enlargeCenterPage: true)),
            ],
          );
        } else if (snapshot.hasError) {
          log(name: 'ERROR', 'Request has errors');
          log(name: 'ERROR', '${snapshot.error.toString()}');
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  FutureBuilder<HousesResponse> buildWaterPieChart() {
    return FutureBuilder<HousesResponse>(
      future: _futureHousesResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          double totalConsumes = 0;
          for (HouseWidget houseWidget in _houseWidgets) {
            totalConsumes += houseWidget.house.total_liters;
          }
          return Column(
            children: [
              drawConsumesTitle(),
              const SizedBox(height: 24.0),
              Text(
                "Total: $totalConsumes L",
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20.0,
                    color: Colors.black),
              ),
              const SizedBox(height: 24.0),
              WaterPieChart(
                houseWidgets: _houseWidgets,
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }

  FutureBuilder<ExpensesResponse> buildExpensesLineChart() {
    return FutureBuilder<ExpensesResponse>(
      future: _futureExpensesResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          for (MonthExpense month in snapshot.data!.months) {
            _monthExpenses.add(MonthExpense(
                date: month.date, cost: month.cost, total: month.total));
          }
          log(name: 'DEBUG', 'Found ${_monthExpenses.length} month(s)');
          double currentPrice = _monthExpenses.last.cost;
          return Column(
            children: [
              drawExpensesTitle(),
              const SizedBox(height: 24.0),
              Text(
                "Current price: $currentPrice €",
                style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 20.0,
                    color: Colors.black),
              ),
              const SizedBox(height: 24.0),
            ],
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
