import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';

import '../../../config/AppConfig.dart';

class ActionsPage extends StatefulWidget {
  const ActionsPage({super.key});

  @override
  State<ActionsPage> createState() => _ActionsPageState();
}

class _ActionsPageState extends State<ActionsPage> {
  String? token;
  int id = -1;

  final HouseClient houseClient = HouseClient(
      url: AppConfig.getBaseUrl(), path: AppConfig.getHouseInfoPath());

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
        //_futureHouseResponse = houseClient.getHouse(token!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      id = arg['id'];
    }

    return Scaffold(
      body: drawBody(),
    );
  }

  Widget drawBody() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(
            top: 32.0, left: 4.0, right: 4.0, bottom: 32.0),
        child: Text('Actions'),
      ),
    );
  }
}
