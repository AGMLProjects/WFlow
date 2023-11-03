import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wflowapp/main/actions/actuator/client/ShowerActuatorClient.dart';
import 'package:wflowapp/main/actions/actuator/client/ShowerActuatorResponse.dart';

import '../../../config/AppConfig.dart';

class ShowerActuatorPage extends StatefulWidget {
  const ShowerActuatorPage({super.key});

  @override
  State<ShowerActuatorPage> createState() => _ShowerActuatorPageState();
}

class _ShowerActuatorPageState extends State<ShowerActuatorPage> {
  String? token;
  int id = -1;
  int sensorId = -1;
  int deviceId = -1;
  String deviceName = '';
  double temperature = 35.0;

  final ShowerActuatorClient client = ShowerActuatorClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getPostActuatorPath());

  Future<ShowerActuatorResponse>? _futureResponse;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      log(name: 'CONFIG', 'Device ID: $deviceId');
      log(name: 'CONFIG', 'Sensor ID: $sensorId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      id = arg['id'];
      sensorId = arg['sensorId'];
      deviceId = arg['deviceId'];
      deviceName = arg['deviceName'];
    }

    return Scaffold(appBar: drawAppBar(), body: drawBody());
  }

  AppBar drawAppBar() {
    return AppBar(title: Text('$deviceName - Shower'));
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

  Widget buildActions() {
    return buildShowerAction();
  }

  Widget buildShowerAction() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose the shower temperature',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumberPicker(
                value: temperature.toInt(),
                minValue: 10,
                maxValue: 45,
                step: 1,
                itemHeight: 60,
                axis: Axis.horizontal,
                haptics: true,
                textStyle: const TextStyle(fontSize: 18),
                selectedTextStyle:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                onChanged: (value) => setState(() {
                  temperature = value.toDouble();
                }),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: getColorFromTemperature(temperature)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text(
                            'This shower will be turned on if not active, do you want to proceed?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () {
                              setState(() {
                                _futureResponse = client.activateShower(
                                    token!, sensorId, deviceId, temperature);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Successfully sent information",
                                    textAlign: TextAlign.center,
                                  ),
                                ));
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    'Toggle',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Color getColorFromTemperature(double temp) {
    if (temp < 20) {
      return const Color.fromARGB(255, 0, 217, 255);
    } else if (temp >= 20 && temp < 26) {
      return const Color.fromARGB(255, 0, 136, 255);
    } else if (temp >= 26 && temp < 35) {
      return const Color.fromARGB(255, 255, 157, 0);
    } else if (temp >= 35 && temp < 41) {
      return const Color.fromARGB(255, 255, 102, 0);
    } else {
      return const Color.fromARGB(255, 255, 47, 0);
    }
  }
}
