import 'package:flutter/material.dart';

import '../../../config/AppConfig.dart';

class EditHousePage extends StatefulWidget {
  const EditHousePage({super.key});

  @override
  State<EditHousePage> createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  String deviceID = '';
  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    deviceID = arg['deviceID'];
    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: const Text('Edit House'));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Device ID: $deviceID')],
        ),
      ),
    );
  }
}
