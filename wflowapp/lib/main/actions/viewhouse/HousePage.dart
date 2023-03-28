import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wflowapp/main/actions/viewhouse/MenuItems.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/GasConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Device.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';
import 'package:wflowapp/main/actions/viewhouse/model/LitersConsumed.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Sensor.dart';

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
      IconButton(
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
      PopupMenuButton(
        tooltip: 'Menu',
        onSelected: (value) {
          if (value == MenuItems.ACTIONS) {
            // do something
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: MenuItems.ACTIONS, child: Text('Actions')),
        ],
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
              const SizedBox(height: 10.0),
              ExpansionTile(
                title: const Text(
                  'Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  ListTile(
                    title: Text(
                        'Total liters consumed: ${house.totalLitersConsumed} L'),
                  ),
                  ListTile(
                    title: Text(
                        'Total liters predicted: ${house.totalLitersPredicted} L'),
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
              const SizedBox(height: 10.0),
              ExpansionTile(
                title: const Text(
                  'Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  ListTile(
                    title: Text(
                        'Total gas consumed: ${house.totalGasConsumed} m3'),
                  ),
                  ListTile(
                    title: Text(
                        'Total gas predicted: ${house.totalGasPredicted} m3'),
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
                'Connected devices',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              for (Device device in house.devices) drawDevice(device),
              const SizedBox(height: 80.0),
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

  Widget drawDevice(Device device) {
    // https://www.youtube.com/watch?v=vRWY-IQAin0
    List<Sensor> sensors = device.sensors;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: ExpansionTile(
        title: Text(
          device.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${sensors.length} sensors'),
        children: [
          for (Sensor sensor in sensors)
            ListTile(title: Text(sensor.sensorType))
        ],
      ),
    );
  }
}
