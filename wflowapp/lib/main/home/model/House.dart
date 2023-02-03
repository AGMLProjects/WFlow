import 'package:flutter/material.dart';

class House {
  final String id;
  final String name;
  final double consumes;
  Color? color;

  House({required this.id, required this.name, this.consumes = 0, this.color});
}
