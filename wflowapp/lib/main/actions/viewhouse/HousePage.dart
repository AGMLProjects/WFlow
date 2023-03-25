import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/GasConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';

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
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
            top: 32.0, left: 4.0, right: 4.0, bottom: 32.0),
        child: buildHouseInfo(),
      ),
    );
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
              const Text(
                'Water consumes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              LitersConsumesChart(consumes: house.litersConsumes),
              const SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total:\n${house.totalLitersConsumed} L',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total predicted:\n${house.totalLitersPredicted} L',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20.0),
              const Divider(
                color: Colors.black,
                thickness: 0.4,
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Gas consumes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              GasConsumesChart(consumes: house.gasConsumes),
              const SizedBox(height: 32.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total:\n${house.totalGasConsumed} m3',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total predicted:\n${house.totalGasPredicted} m3',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20.0),
              const Divider(
                color: Colors.black,
                thickness: 0.4,
              ),
              const SizedBox(height: 20.0),
            ],
          );
        } else if (snapshot.hasError) {
          log(name: 'DEBUG', 'Request in error');
          log(name: 'DEBUG', snapshot.error.toString());
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
