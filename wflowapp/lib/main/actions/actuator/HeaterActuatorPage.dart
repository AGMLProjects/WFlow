import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wflowapp/main/actions/actuator/client/HeaterActuatorClient.dart';
import 'package:wflowapp/main/actions/actuator/client/HeaterActuatorResponse.dart';
import 'package:wflowapp/main/actions/actuator/client/ShowerActuatorResponse.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';

import '../../../config/AppConfig.dart';

class HeaterActuatorPage extends StatefulWidget {
  const HeaterActuatorPage({super.key});

  @override
  State<HeaterActuatorPage> createState() => _HeaterActuatorPageState();
}

class _HeaterActuatorPageState extends State<HeaterActuatorPage> {
  String? token;
  int id = -1;
  int sensorId = -1;
  int deviceId = -1;
  String deviceName = '';
  bool automatic = false;
  bool manuallySet = false;
  bool active = false;

  List<int> temperatures = [];
  List<DateTime> starts = [];
  List<DateTime> ends = [];

  final HeaterActuatorClient client = HeaterActuatorClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getPostActuatorPath());

  Future<HeaterActuatorResponse>? _futureGetResponse;
  Future<HeaterActuatorResponse>? _futurePostResponse;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      log(name: 'CONFIG', 'Device ID: $deviceId');
      log(name: 'CONFIG', 'Sensor ID: $sensorId');
      setState(() {
        _futureGetResponse = client.getHeater(token!, sensorId, deviceId);
      });
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
    return AppBar(title: Text('$deviceName - Smart Heater'));
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

  FutureBuilder<HeaterActuatorResponse> buildActions() {
    return FutureBuilder<HeaterActuatorResponse>(
      future: _futureGetResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          log('Request ok');
          active = snapshot.data!.active;
          automatic = snapshot.data!.automatic;
          temperatures = snapshot.data!.temperatures;
          starts = snapshot.data!.starts;
          ends = snapshot.data!.ends;
          return buildSmartHeaterAction();
        } else if (snapshot.hasError) {
          log(name: 'DEBUG', 'Request in error: ${snapshot.error.toString()}');
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildSmartHeaterAction() {
    return Container(
      margin: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Smart Heater status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Row(
                children: [
                  Text(
                    active ? 'ON' : 'OFF',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.brightness_1_rounded,
                    color: active ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: request
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Successfully sent information",
                      textAlign: TextAlign.center,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    active ? 'Turn OFF' : 'Turn ON',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
                  value: automatic,
                  onChanged: (value) {
                    setState(() {
                      automatic = value;
                      if (value) {
                        manuallySet = false;
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
                  value: manuallySet,
                  onChanged: (value) {
                    setState(() {
                      manuallySet = value;
                      if (value) {
                        automatic = false;
                      }
                    });
                  })
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color:
                      manuallySet ? AppConfig.getDefaultColor() : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  if (manuallySet) {
                    // TODO
                    log('Add activation');
                  }
                },
              )
            ],
          ),
          const SizedBox(height: 20),
          AbsorbPointer(absorbing: !manuallySet, child: buildActivations()),
          const SizedBox(height: 20),
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

  Widget buildActivations() {
    int n_activations = temperatures.length;
    List<Widget> activations = [];
    for (var i = 0; i < n_activations; i++) {
      activations.add(buildActivation(i));
    }
    return Container(
        color: !manuallySet
            ? const Color.fromARGB(50, 204, 204, 204)
            : const Color.fromARGB(0, 0, 0, 0),
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Column(
          children: activations,
        ));
  }

  Widget buildActivation(int index) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Text(
              (index + 1).toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                const Row(
                  children: [
                    Text(
                      'Temperature',
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
                            value: temperatures[index],
                            minValue: 10,
                            maxValue: 30,
                            step: 1,
                            itemHeight: 25,
                            itemWidth: 30,
                            itemCount: 3,
                            axis: Axis.vertical,
                            haptics: true,
                            textStyle: const TextStyle(fontSize: 14),
                            selectedTextStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            onChanged: (value) => setState(() {
                                  temperatures[index] = value;
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
                            value: starts[index].hour,
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
                                  starts[index] = DateTime(
                                      2023, 1, 1, value, starts[index].minute);
                                })),
                        const Text(
                          ':',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        NumberPicker(
                            value: starts[index].minute,
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
                                  starts[index] = DateTime(
                                      2023, 1, 1, starts[index].hour, value);
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
                            value: ends[index].hour,
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
                                  ends[index] = DateTime(
                                      2023, 1, 1, value, ends[index].minute);
                                })),
                        const Text(
                          ':',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        NumberPicker(
                            value: ends[index].minute,
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
                                  ends[index] = DateTime(
                                      2023, 1, 1, ends[index].hour, value);
                                })),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 38)
      ],
    );
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
