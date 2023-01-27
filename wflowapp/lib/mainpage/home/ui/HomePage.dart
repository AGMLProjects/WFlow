import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
  List<House> _houses = [];
  List<HouseWidget> _houseWidgets = [];
  List<MonthExpense> _monthExpenses = [];

  final HousesClient housesClient =
      const HousesClient(url: AppConfig.BASE_URL, path: '/houses');

  final ExpensesClient expensesClient =
      const ExpensesClient(url: AppConfig.BASE_URL, path: '/expenses');

  Future<HousesResponse>? _futureHousesResponse;
  Future<ExpensesResponse>? _futureExpensesResponse;

  @override
  Widget build(BuildContext context) {
    setState(() {
      _futureHousesResponse = housesClient.getHouses("AAAA");
      _futureExpensesResponse = expensesClient.getExpenses("AAAA");
    });

    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(
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
                  buildCostChart(),
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

  Widget drawCostTitle() {
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
            _houseWidgets.add(HouseWidget(
              house: house,
              isAdd: false,
            ));
          }
          _houseWidgets.add(HouseWidget(
            house: const House(name: ''),
            isAdd: true,
          ));
          log('Found ${_houseWidgets.length - 1} house(s)');
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
                "$totalConsumes L",
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

  FutureBuilder<ExpensesResponse> buildCostChart() {
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
          log('Found ${_monthExpenses.length} month(s)');
          double currentPrice = _monthExpenses.last.cost;
          return Column(
            children: [
              drawCostTitle(),
              const SizedBox(height: 24.0),
              Text(
                "$currentPrice \$",
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
