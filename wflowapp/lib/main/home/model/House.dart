import 'package:flutter/material.dart';

class House {
  final int house_id;
  final int user_id;
  final String name;
  final String address;
  final String city;
  final String region;
  final String country;
  final String house_type;
  final dynamic total_liters;
  final dynamic total_gas;
  Color? color;

  House(
      {required this.house_id,
      this.user_id = 0,
      required this.name,
      this.address = '',
      this.city = '',
      this.region = '',
      this.country = '',
      this.house_type = '',
      this.total_liters = 0,
      this.total_gas = 0});
}
