import 'package:flutter/material.dart';

class House {
  final int house_id;
  final int user_id;
  final dynamic total_liters;
  final dynamic total_gas;
  final dynamic future_total_liters;
  final dynamic future_total_gas;
  final String name;
  final String address;
  final String city;
  final String house_type;
  Color? color;

  House(
      {required this.house_id,
      required this.name,
      this.user_id = 0,
      this.total_liters = 0.0,
      this.total_gas = 0.0,
      this.future_total_liters = 0.0,
      this.future_total_gas = 0.0,
      this.address = '',
      this.city = '',
      this.house_type = ''});
}
