import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/GasConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';

import '../../../config/AppConfig.dart';
import 'client/HouseResponse.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  String? token;
  Color? color;
  int id = -1;
  String name = '';
  String city = '';
  String address = '';
  String type = '';

  final HouseClient houseClient = HouseClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getHouseInfoPath());

  Future<HouseResponse>? _futureHouseResponse;

  @override
  void initState() {
    super.initState();
    String? token;
    Future.delayed(Duration.zero, () {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      color = AppConfig.getHouseColor(id);
      setState(() {
        houseClient.path = houseClient.path.replaceAll('{id}', id.toString());
        _futureHouseResponse = houseClient.getHouse(token!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    id = arg['id'];
    name = arg['name'];
    city = arg['city'];
    address = arg['address'];
    type = arg['type'];

    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
      floatingActionButton: drawFAB(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: Text(name), actions: <Widget>[
      Container(
        child: IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 20.0,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/editHouse', arguments: {
              'id': id,
              'name': name,
              'city': city,
              'address': address,
              'type': type
            });
          },
        ),
      )
    ]);
  }

  Widget drawBody() {
    return Container(
        padding: const EdgeInsets.all(20.0), child: buildHouseInfo());
  }

  FutureBuilder<HouseResponse> buildHouseInfo() {
    return FutureBuilder<HouseResponse>(
      future: _futureHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          House house = snapshot.data!.house;
          return Column(
            children: [
              const Text('Water consumes chart'),
              LitersConsumesChart(consumes: house.litersConsumes),
              Text('Total water consumed: ${house.totalLitersConsumed}'),
              Text('Predicted water consumes: ${house.totalLitersPredicted}'),
              const Text('Gas consumes chart'),
              GasConsumedChart(consumes: house.gasConsumed),
              Text('Total gas consumed: ${house.totalGasConsumed}'),
              Text('Predicted gas consumes: ${house.totalGasPredicted}'),
            ],
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget drawFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/addDevice', arguments: {'id': id});
      },
      tooltip: 'Add Device',
      child: const Icon(Icons.add),
    );
  }

  Widget drawSensor() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 10.0,
      child: InkWell(
        onTap: () {
          // nothing
        },
        child: SizedBox(
          width: 500.0,
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
