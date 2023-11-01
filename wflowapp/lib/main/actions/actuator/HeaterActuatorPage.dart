import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/actuator/HeaterActuatorActivation.dart';
import 'package:wflowapp/main/actions/actuator/client/HeaterActuatorClient.dart';

import '../../../config/AppConfig.dart';
import 'client/HeaterActuatorResponseGet.dart';

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
  bool status = false;
  List<double> temperatures = [];
  List<DateTime> starts = [];
  List<DateTime> ends = [];

  List<HeaterActuatorActivation> activations = [];

  bool fetched = false;

  final HeaterActuatorClient client = HeaterActuatorClient(
      url: AppConfig.getBaseUrl(),
      get_path: AppConfig.getGetActuatorPath(),
      post_path: AppConfig.getPostActuatorPath());

  Future<HeaterActuatorResponseGet>? _futureGetResponse;

  void fetchData() {
    if (!fetched) {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      log(name: 'CONFIG', 'Device ID: $deviceId');
      log(name: 'CONFIG', 'Sensor ID: $sensorId');
      setState(() {
        _futureGetResponse = client.getHeater(token!, sensorId);
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, fetchData);
    super.initState();
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

  FutureBuilder<HeaterActuatorResponseGet> buildActions() {
    return FutureBuilder<HeaterActuatorResponseGet>(
      future: _futureGetResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          log('Request ok');
          if (!fetched) {
            status = snapshot.data!.status;
            automatic = snapshot.data!.automatic;
            temperatures = snapshot.data!.temperatures;
            starts = snapshot.data!.starts;
            ends = snapshot.data!.ends;

            fetched = true;
          }
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
                    status ? 'ON' : 'OFF',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.brightness_1_rounded,
                    color: status ? Colors.green : Colors.red,
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content: Text('Are you sure you want to turn ' +
                            (status ? 'OFF' : 'ON') +
                            ' the smart heater?'),
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
                                  temperatures = [];
                                  starts = [];
                                  ends = [];
                                  for (HeaterActuatorActivation activation
                                      in activations) {
                                    temperatures
                                        .add(activation.temperature.toDouble());
                                    starts.add(activation.start_timestamp);
                                    ends.add(activation.end_timestamp);
                                  }
                                  status = !status;
                                  log('Locally updated values');
                                  client.setHeater(token!, sensorId, status,
                                      automatic, temperatures, starts, ends);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                      "Successfully sent information",
                                      textAlign: TextAlign.center,
                                    ),
                                  ));
                                });
                                Navigator.of(context).pop();
                              })
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    status ? 'Turn OFF' : 'Turn ON',
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
                    setState(() {
                      HeaterActuatorActivation last =
                          activations[activations.length - 1];
                      HeaterActuatorActivation activation =
                          HeaterActuatorActivation(
                              index: last.index + 1,
                              temperature: 30,
                              start_timestamp: last.end_timestamp,
                              end_timestamp: DateTime(
                                  last.end_timestamp.year,
                                  last.end_timestamp.month,
                                  last.end_timestamp.hour + 1,
                                  last.end_timestamp.minute),
                              to_delete: false);
                      activations.add(activation);
                    });
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
                  temperatures = [];
                  starts = [];
                  ends = [];
                  for (HeaterActuatorActivation activation in activations) {
                    temperatures.add(activation.temperature.toDouble());
                    starts.add(activation.start_timestamp);
                    ends.add(activation.end_timestamp);
                  }
                  log('Locally updated values');
                  client.setHeater(token!, sensorId, status, automatic,
                      temperatures, starts, ends);
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
    if (activations.isEmpty) {
      for (var i = 0; i < n_activations; i++) {
        HeaterActuatorActivation activation = HeaterActuatorActivation(
            index: i + 1,
            temperature: temperatures[i].toInt(),
            start_timestamp: starts[i],
            end_timestamp: ends[i],
            to_delete: false);
        activations.add(activation);
      }
    }
    return Column(
      children: activations,
    );
  }
}
