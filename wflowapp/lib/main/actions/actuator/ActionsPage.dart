import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseResponseAPI.dart';
import 'package:wflowapp/main/actions/viewhouse/model/HouseResponse.dart';

import '../../../config/AppConfig.dart';
import '../viewhouse/model/Device.dart';
import '../viewhouse/model/House.dart';
import '../viewhouse/model/Sensor.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  String? token;
  int id = -1;
  Map<int, int> showerSensorMap = {};
  Map<int, Sensor> smartHeaterSensorMap = {};

  final HouseClient houseClient = HouseClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getHouseInfoPath());

  Future<HouseResponseAPI>? _futureHouseResponse;

  @override
  void initState() {
    super.initState();
    String? token;
    Future.delayed(Duration.zero, () {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      setState(() {
        houseClient.path = houseClient.path.replaceAll('{id}', id.toString());
        _futureHouseResponse = houseClient.getHouse(token!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      id = arg['id'];
    }

    return Scaffold(appBar: drawAppBar(), body: drawBody());
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Actions'));
  }

  Widget drawBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
            top: 32.0, left: 4.0, right: 4.0, bottom: 32.0),
        child: buildActions(),
      ),
    );
  }

  FutureBuilder<HouseResponseAPI> buildActions() {
    return FutureBuilder<HouseResponseAPI>(
      future: _futureHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          HouseResponse houseResponse = snapshot.data!.houseResponse;
          return buildActionsFromHouseResponse(houseResponse);
        } else if (snapshot.hasError) {
          log(name: 'DEBUG', 'Request in error: ${snapshot.error.toString()}');
          //dynamic json = jsonDecode(AppConfig.getFakeHouseInfo());
          //House house = House.fromJson(json);
          //return buildFromHouse(house);
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildActionsFromHouseResponse(HouseResponse houseResponse) {
    return Column(
      children: [
        for (Device device in houseResponse.devices) buildAction(device),
        const SizedBox(height: 120.0),
      ],
    );
  }

  Widget buildAction(Device device) {
    var sensors = [];
    for (Sensor sensor in device.sensors) {
      if (sensor.sensor_type == 'SAC') {
        if (!showerSensorMap.containsKey(sensor.sensor_id)) {
          showerSensorMap[sensor.sensor_id] = sensor.sensor_id;
        }
        sensors.add(sensor);
      } else if (sensor.sensor_type == 'HAC') {
        if (!smartHeaterSensorMap.containsKey(sensor.sensor_id)) {
          smartHeaterSensorMap[sensor.sensor_id] = sensor;
        }
        sensors.add(sensor);
      }
    }
    String subtitleText = sensors.isNotEmpty
        ? '${sensors.length} sensors with possible actions'
        : 'No Showers or Smart Heaters found';
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 30),
      child: ExpansionTile(
        title: Text(
          'Connected to "${device.name}"',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitleText),
        children: [for (Sensor sensor in sensors) _buildAction(device, sensor)],
      ),
    );
  }

  Widget _buildAction(Device device, Sensor sensor) {
    String sensorTytle = 'Smart Heater';
    if (sensor.sensor_type == 'SAC') {
      sensorTytle = 'Shower (actuator)';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sensorTytle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          ElevatedButton(
            onPressed: () {
              if (sensor.sensor_type == 'SAC') {
                Navigator.pushNamed(context, '/showerAction', arguments: {
                  'id': id,
                  'sensorId': sensor.sensor_id,
                  'deviceId': device.device_id,
                  'deviceName': device.name
                });
              } else {
                Navigator.pushNamed(context, '/heaterAction', arguments: {
                  'id': id,
                  'sensorId': sensor.sensor_id,
                  'deviceId': device.device_id,
                  'deviceName': device.name
                });
              }
            },
            style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
            child: const Text(
              'Actions',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
