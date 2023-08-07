import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';

import '../../../config/AppConfig.dart';
import '../viewhouse/client/HouseResponse.dart';
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

  Future<HouseResponse>? _futureHouseResponse;

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

  FutureBuilder<HouseResponse> buildActions() {
    return FutureBuilder<HouseResponse>(
      future: _futureHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          House house = snapshot.data!.house;
          return buildActionsFromHouse(house);
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

  Widget buildActionsFromHouse(House house) {
    return Column(
      children: [
        for (Device device in house.devices) buildAction(device),
        const SizedBox(height: 120.0),
      ],
    );
  }

  Widget buildAction(Device device) {
    var sensors = [];
    for (Sensor sensor in device.sensors) {
      // TODO: change!!!
      if (sensor.type == 'LEV') {
        if (!showerSensorMap.containsKey(sensor.id)) {
          showerSensorMap[sensor.id] = 22;
        }
        if (!smartHeaterSensorMap.containsKey(sensor.id)) {
          smartHeaterSensorMap[sensor.id] = sensor;
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
        children: [for (Sensor sensor in sensors) _buildAction(sensor)],
      ),
    );
  }

  Widget _buildAction(Sensor sensor) {
    // TODO: change
    if (sensor.type == '') {
      return buildShowerAction(sensor);
    } else {
      return buildSmartHeaterAction(sensor);
    }
  }

  Widget buildShowerAction(Sensor sensor) {
    return Container(
      margin: EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Shower sensor',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose the shower temperature',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NumberPicker(
                value: showerSensorMap[sensor.id]!,
                minValue: 10,
                maxValue: 30,
                step: 1,
                itemHeight: 60,
                axis: Axis.horizontal,
                haptics: true,
                textStyle: const TextStyle(fontSize: 14),
                selectedTextStyle:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                onChanged: (value) => setState(() {
                  showerSensorMap[sensor.id] = value;
                }),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color:
                          getColorFromTemperature(showerSensorMap[sensor.id]!)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
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
                                // TODO: turn on call
                                // TODO: request
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    "Successfully saved information",
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

  Widget buildSmartHeaterAction(Sensor sensor) {
    return Container(
      margin: const EdgeInsets.all(18),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Smart Heater',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 280,
                child: Text(
                  'Automatically optimize Smart Heater activation based on your routine',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              Switch(
                  value: smartHeaterSensorMap[sensor.id]!.automatic,
                  onChanged: (value) {
                    setState(() {
                      smartHeaterSensorMap[sensor.id]!.automatic = value;
                      if (value) {
                        smartHeaterSensorMap[sensor.id]!.set = false;
                      }
                    });
                  })
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 280,
                child: Text(
                  'Set manually when turn on and off your Smart Heater',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ),
              Switch(
                  value: smartHeaterSensorMap[sensor.id]!.set,
                  onChanged: (value) {
                    setState(() {
                      smartHeaterSensorMap[sensor.id]!.set = value;
                      if (value) {
                        smartHeaterSensorMap[sensor.id]!.automatic = false;
                      }
                    });
                  })
            ],
          ),
          const SizedBox(height: 24),
          AbsorbPointer(
              absorbing: !smartHeaterSensorMap[sensor.id]!.set,
              child: buildActivations(sensor)),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: request
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Successfully saved information",
                      textAlign: TextAlign.center,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    'Save',
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

  Widget buildActivations(Sensor sensor) {
    return Container(
        color: !smartHeaterSensorMap[sensor.id]!.set
            ? Color.fromARGB(50, 204, 204, 204)
            : Color.fromARGB(0, 0, 0, 0),
        padding: EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Activation #1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Start',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          children: [
                            NumberPicker(
                                value: 10,
                                minValue: 0,
                                maxValue: 23,
                                step: 1,
                                itemHeight: 25,
                                itemWidth: 30,
                                itemCount: 3,
                                zeroPad: true,
                                axis: Axis.vertical,
                                haptics: true,
                                textStyle: const TextStyle(fontSize: 14),
                                selectedTextStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value) => setState(() {
                                      showerSensorMap[sensor.id] = value;
                                    })),
                            const Text(
                              ':',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            NumberPicker(
                                value: 10,
                                minValue: 0,
                                maxValue: 59,
                                step: 1,
                                itemHeight: 25,
                                itemWidth: 30,
                                itemCount: 3,
                                zeroPad: true,
                                axis: Axis.vertical,
                                haptics: true,
                                textStyle: const TextStyle(fontSize: 14),
                                selectedTextStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value) => setState(() {
                                      showerSensorMap[sensor.id] = value;
                                    })),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Row(
                      children: [
                        Text(
                          'End',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          children: [
                            NumberPicker(
                                value: 10,
                                minValue: 0,
                                maxValue: 23,
                                step: 1,
                                itemHeight: 25,
                                itemWidth: 30,
                                itemCount: 3,
                                zeroPad: true,
                                axis: Axis.vertical,
                                haptics: true,
                                textStyle: const TextStyle(fontSize: 14),
                                selectedTextStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value) => setState(() {
                                      showerSensorMap[sensor.id] = value;
                                    })),
                            const Text(
                              ':',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            NumberPicker(
                                value: 10,
                                minValue: 0,
                                maxValue: 59,
                                step: 1,
                                itemHeight: 25,
                                itemWidth: 30,
                                itemCount: 3,
                                zeroPad: true,
                                axis: Axis.vertical,
                                haptics: true,
                                textStyle: const TextStyle(fontSize: 14),
                                selectedTextStyle: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                onChanged: (value) => setState(() {
                                      showerSensorMap[sensor.id] = value;
                                    })),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ],
            )
          ],
        ));
  }

  Color getColorFromTemperature(int temp) {
    if (temp < 14) {
      return const Color.fromARGB(255, 0, 217, 255);
    } else if (temp >= 14 && temp < 18) {
      return const Color.fromARGB(255, 0, 136, 255);
    } else if (temp >= 18 && temp < 22) {
      return const Color.fromARGB(255, 255, 157, 0);
    } else if (temp >= 22 && temp < 26) {
      return const Color.fromARGB(255, 255, 102, 0);
    } else {
      return const Color.fromARGB(255, 255, 47, 0);
    }
  }
}
