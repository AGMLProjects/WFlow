import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/MenuItems.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/GasConsumesBarChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/Indicator.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesBarChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/LitersConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/charts/GasConsumesChart.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Device.dart';
import 'package:wflowapp/main/actions/viewhouse/model/Event.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';
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
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      id = arg['id'];
      name = arg['name'];
      city = arg['city'];
      address = arg['address'];
      type = arg['type'];
    }

    return Scaffold(
      appBar: drawAppBar(),
      body: RefreshIndicator(onRefresh: _pullRefresh, child: drawBody()),
      floatingActionButton: drawFAB(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: Text(name), actions: <Widget>[
      PopupMenuButton(
        tooltip: 'Menu',
        onSelected: (value) {
          if (value == MenuItems.ACTIONS) {
            Navigator.pushNamed(context, '/actions', arguments: {'id': id});
          } else if (value == MenuItems.EDIT) {
            Navigator.pushNamed(context, '/editHouse', arguments: {
              'id': id,
              'name': name,
              'city': city,
              'address': address,
              'type': type
            });
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: MenuItems.ACTIONS, child: Text('Actions')),
          const PopupMenuItem(value: MenuItems.EDIT, child: Text('Edit house')),
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

  Future<void> _pullRefresh() async {
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

  FutureBuilder<HouseResponse> buildHouseInfo() {
    return FutureBuilder<HouseResponse>(
      future: _futureHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          House house = snapshot.data!.house;
          return buildFromHouse(house);
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

  Widget buildFromHouse(House house) {
    String month =
        toStringMonth(house.litersConsumes.elementAt(0).x.split("/")[1]);
    return Column(
      children: [
        Text(
          'Water consumes ($month)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        LitersConsumesChart(consumes: house.litersConsumes),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20),
          child: Column(
            children: [
              Indicator(
                  color: Colors.cyan, text: 'Real consumes', isSquare: true),
              SizedBox(height: 4.0),
              Indicator(
                  color: Color.fromARGB(200, 195, 195, 195),
                  text: 'Predicted consumes',
                  isSquare: true),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        ExpansionTile(
          title: const Text(
            'Other statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: [
            ListTile(
              title:
                  Text('Total liters consumed: ${house.totalLitersConsumed} L'),
            ),
            ListTile(
              title: Text(
                  'Total liters predicted: ${house.totalLitersPredicted} L'),
            )
          ],
        ),
        const SizedBox(height: 20.0),
        const Divider(color: Colors.black, thickness: 0.4),
        const SizedBox(height: 20.0),
        const Text(
          'This week water consumes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        LitersConsumesBarChart(consumes: house.weeklyLitersConsumes),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: const [
              Indicator(
                  color: Color.fromARGB(200, 195, 195, 195),
                  text: 'Average consumes',
                  isSquare: true),
              SizedBox(height: 4.0),
              Indicator(
                  color: Colors.cyan,
                  text: 'Actual consumes (this week)',
                  isSquare: true),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        const Divider(color: Colors.black, thickness: 0.4),
        const SizedBox(height: 20.0),
        Text(
          'Gas consumes ($month)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        GasConsumesChart(consumes: house.gasConsumes),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Column(
            children: const [
              Indicator(
                  color: Colors.cyan, text: 'Real consumes', isSquare: true),
              SizedBox(height: 4.0),
              Indicator(
                  color: Color.fromARGB(200, 195, 195, 195),
                  text: 'Predicted consumes',
                  isSquare: true),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        ExpansionTile(
          title: const Text(
            'Other statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          children: [
            ListTile(
              title: Text('Total gas consumed: ${house.totalGasConsumed} m3'),
            ),
            ListTile(
              title: Text('Total gas predicted: ${house.totalGasPredicted} m3'),
            )
          ],
        ),
        const SizedBox(height: 20.0),
        const Divider(color: Colors.black, thickness: 0.4),
        const SizedBox(height: 20.0),
        Text(
          'This week gas consumes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        GasConsumesBarChart(consumes: house.weeklyGasConsumes),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: const [
              Indicator(
                  color: Color.fromARGB(200, 195, 195, 195),
                  text: 'Average consumes',
                  isSquare: true),
              SizedBox(height: 4.0),
              Indicator(
                  color: Colors.cyan,
                  text: 'Actual consumes (this week)',
                  isSquare: true),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
        const Divider(color: Colors.black, thickness: 0.4),
        const SizedBox(height: 20.0),
        const Text(
          'Connected devices',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        for (Device device in house.devices) drawDevice(device),
        const SizedBox(height: 20.0),
        const Divider(color: Colors.black, thickness: 0.4),
        const SizedBox(height: 20.0),
        const Text(
          'Recent events',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 20.0),
        Container(
          height: 200.0,
          child: ListView.builder(
            itemCount: house.recentEvents.length,
            itemBuilder: (context, index) {
              final Event event = house.recentEvents[index];
              return ListTile(
                title: Text('• ${event.description}'),
              );
            },
          ),
        ),
        const SizedBox(height: 120.0),
      ],
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
          'Connected to "${device.name}"',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${sensors.length} sensors'),
        children: [
          for (Sensor sensor in sensors)
            ListTile(title: Text(translateSensor(sensor.type)))
        ],
      ),
    );
  }

  String translateSensor(String code) {
    switch (code) {
      case "FLO":
        return "Tap sensor";
      case "HEA":
        return "Smart heater";
      case "LEV":
        return "Flush sensor";
      default:
        return "Sensor";
    }
  }

  String toStringMonth(String monthStr) {
    int month = int.parse(monthStr);
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }
}
