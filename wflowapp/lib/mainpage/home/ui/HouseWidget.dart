import 'package:flutter/material.dart';
import 'dart:math';

class HouseWidget extends StatelessWidget {
  const HouseWidget({super.key, this.title = ""});

  final String title;

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
    if (title.isEmpty) {
      return Container(
        width: 500.0,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            Icons.add,
            color: Colors.grey,
            size: 40.0,
          ),
        ),
      );
    }
    return Container(
      width: 500.0,
      decoration: BoxDecoration(
          color: _pickRandomColor(), borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  Color _pickRandomColor() {
    final rnd = Random();
    Color color = colors.elementAt(rnd.nextInt(colors.length));
    colors.remove(color);
    return color;
  }
}
