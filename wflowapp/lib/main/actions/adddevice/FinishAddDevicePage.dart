import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/adddevice/client/AddDeviceClient.dart';
import 'package:wflowapp/main/actions/adddevice/client/AddDeviceResponse.dart';

class FinishAddDevicePage extends StatefulWidget {
  const FinishAddDevicePage({super.key});

  @override
  State<FinishAddDevicePage> createState() => _FinishAddDevicePageState();
}

class _FinishAddDevicePageState extends State<FinishAddDevicePage> {
  String? token;
  int? id;
  String? devId;

  final nameController = TextEditingController();

  final AddDeviceClient addDeviceClient = AddDeviceClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getAddDevicePath());

  Future<AddDeviceResponse>? _futureAddDeviceResponse;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      token = AppConfig.getUserToken();
      log(name: 'CONFIG', 'Token: ${token!}');
      log(name: 'CONFIG', 'House ID: $id');
      log(name: 'CONFIG', 'Device ID: $devId');
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    id = arg['id'];
    if (arg['devId'] == null) {
      devId = '';
    } else {
      devId = arg['devId'];
    }
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Add Device'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            drawInstructions(),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Device Name',
                  hintText: 'Device Name'),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => performRequest(),
              style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Done',
                  style: TextStyle(fontSize: 22.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            if (_futureAddDeviceResponse != null) drawAddDeviceResponse(),
          ],
        ),
      ),
    );
  }

  void performRequest() {
    setState(() {
      String name = nameController.text;
      _futureAddDeviceResponse =
          addDeviceClient.addDevice(token!, id!, devId!, name);
    });
  }

  Widget drawInstructions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(
                  text:
                      'You can assign a name to your device. Note that, if you don\'t set the name, a default value will be used',
                  style: TextStyle(color: Colors.grey))
            ],
          ),
        ),
      ],
    );
  }

  FutureBuilder<AddDeviceResponse> drawAddDeviceResponse() {
    return FutureBuilder<AddDeviceResponse>(
      future: _futureAddDeviceResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 201) {
            return const Text('Error',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ));
          }
          log(name: 'DEBUG', 'Message: ${snapshot.data!.message}');
          Future.delayed(Duration.zero, () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                "Successfully added device",
                textAlign: TextAlign.center,
              ),
            ));
            Navigator.pushReplacementNamed(context, '/main');
          });
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ));
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
