import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/mainpage/home/rest/ExpensesResponse.dart';
import 'package:wflowapp/mainpage/home/rest/HousesClient.dart';
import 'package:wflowapp/mainpage/home/rest/HousesResponse.dart';
import 'package:wflowapp/mainpage/home/rest/MonthExpense.dart';
import 'package:wflowapp/mainpage/home/ui/HouseWidget.dart';

import '../rest/ExpensesClient.dart';
import '../rest/House.dart';
import 'charts/CostLineChart.dart';
import 'charts/WaterPieChart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<HouseWidget> _houseWidgets = [];
  final List<MonthExpense> _monthExpenses = [];

  final HousesClient housesClient =
      HousesClient(url: AppConfig.getBaseUrl(), path: '/houses');

  final ExpensesClient expensesClient =
      ExpensesClient(url: AppConfig.getBaseUrl(), path: '/expenses');

  Future<HousesResponse>? _futureHousesResponse;
  Future<ExpensesResponse>? _futureExpensesResponse;

  @override
  void initState() {
    super.initState();
    AppConfig.setUserToken('AAAA'); // TODO: remove this
    String? token = AppConfig.getUserToken();
    log(name: 'CONFIG', 'Token: ${token!}');
    _futureHousesResponse = housesClient.getHouses(token);
    _futureExpensesResponse = expensesClient.getExpenses(token);
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
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildHousesCarousel(),
                  const SizedBox(height: 32.0),
                  buildWaterPieChart(),
                  const SizedBox(height: 32.0),
                  buildExpensesLineChart(),
                  const SizedBox(height: 32.0),
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
            log(name: 'DEBUG', 'Found "${house.name}" (ID: ${house.id})');
            Color? color = AppConfig.getHouseColor(house.id);
            if (color == null) {
              color = AppConfig.getDefaultColor();
            }
            AppConfig.setHouseColor(house.id, color);
            house.color = color;
            _houseWidgets.add(HouseWidget(house: house));
          }
          _houseWidgets.add(HouseWidget(house: House(id: '', name: '')));
          return Column(
            children: [
              drawHousesTitle(),
              const SizedBox(height: 16.0),
              CarouselSlider(
                  items: _houseWidgets,
                  options: CarouselOptions(
                      height: 170.0,
                      enableInfiniteScroll: false,
                      autoPlay: false,
                      enlargeCenterPage: true)),
            ],
          );
        } else if (snapshot.hasError) {
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
            totalConsumes += houseWidget.house.consumes;
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
              CostLineChart(
                months: _monthExpenses,
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
}
