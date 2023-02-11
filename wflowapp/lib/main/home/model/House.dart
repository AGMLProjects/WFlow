import 'package:flutter/material.dart';

class House {
  final String id;
  final String name;
  final double total_expenses;
  final String address;
  final String city;
  Color? color;

  House(
      {required this.id,
      required this.name,
      this.total_expenses = 0,
      this.color,
      this.address = '',
      this.city = ''});
}
