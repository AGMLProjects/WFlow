import 'package:flutter/material.dart';
import 'dart:math';

import '../rest/House.dart';

class HouseWidget extends StatelessWidget {
  HouseWidget({super.key, required this.house, required this.isAdd});

  final House house;
  final bool isAdd;
  final Color color = HouseWidget._pickRandomColor();

  static Set<Color> colors = {
    Colors.amber[200]!,
    Colors.blue[200]!,
    Colors.green[200]!,
    Colors.purple[200]!,
    Colors.orangeAccent[200]!,
    Colors.pink[200]!,
    Colors.lime[200]!,
    Colors.teal[200]!,
    Colors.cyan[200]!
  };

  @override
  Widget build(BuildContext context) {
    if (house.name.isEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, 'addHouse');
        },
        child: Container(
          width: 500.0,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.add,
              color: Colors.grey,
              size: 40.0,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'house',
            arguments: {'id': house.id, 'name': house.name});
      },
      child: Container(
        width: 500.0,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                house.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _pickRandomColor() {
    final rnd = Random();
    Color color = colors.elementAt(rnd.nextInt(colors.length));
    return color;
  }
}
