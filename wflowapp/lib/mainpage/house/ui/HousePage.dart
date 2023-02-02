import 'package:flutter/material.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  String id = '';
  String name = '';

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
    return AppBar(title: Text(name));
  }

  Widget drawBody() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [Text('${'House page (' + id.toString()})')],
      ),
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
