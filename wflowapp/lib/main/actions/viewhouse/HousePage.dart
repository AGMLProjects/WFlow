import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wflowapp/main/actions/viewhouse/client/HouseClient.dart';

import '../../../config/AppConfig.dart';
import 'client/HouseResponse.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  late SharedPreferences prefs;
  String token = '';
  Color? color;

  String id = '';
  String name = '';

  final HouseClient houseClient =
      HouseClient(url: AppConfig.getBaseUrl(), path: '/house');

  Future<HouseResponse>? _futureHouseResponse;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('token', 'AAAA'); // TODO: remove
    token = prefs.getString('token')!;
    log('Token: $token');
    color = Color(prefs.getInt('$id.color')!);
    final futureHouseResponse = houseClient.getHouse(token, id);
    setState(() {
      _futureHouseResponse = futureHouseResponse;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as Map;
    id = arg['id'];
    name = arg['name'];

    return Scaffold(
      appBar: drawAppBar(),
      body: drawBody(),
      floatingActionButton: drawFAB(),
    );
  }

  AppBar drawAppBar() {
    return AppBar(title: Text(name), actions: <Widget>[
      Container(
        child: IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 20.0,
          ),
          onPressed: () {
            Navigator.pushNamed(context, 'editHouse',
                arguments: {'id': id, 'name': name});
          },
        ),
      )
    ]);
  }

  Widget drawBody() {
    return Container(
        padding: const EdgeInsets.all(20.0), child: buildHouseInfo());
  }

  FutureBuilder<HouseResponse> buildHouseInfo() {
    return FutureBuilder<HouseResponse>(
      future: _futureHouseResponse,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.code != 200) {
            return const SizedBox.shrink();
          }
          String houseName = snapshot.data!.house.name;
          return Container(
            child: Text('$houseName'),
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget drawFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, 'addDevice');
      },
      tooltip: 'Add Device',
      child: const Icon(Icons.add),
    );
  }
}
