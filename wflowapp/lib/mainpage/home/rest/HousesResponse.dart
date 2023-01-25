import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

import 'House.dart';

class HousesResponse {
  final int code;
  final List<House> houses;
  final String message;

  const HousesResponse(
      {required this.code, required this.houses, required this.message});

  factory HousesResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    List<dynamic> _dhouses = json['houses'];
    List<House> houses = [];
    for (var _dhouse in _dhouses) {
      House house = House(name: _dhouse['name'], consumes: 0);
      houses.add(house);
    }
    return HousesResponse(
      code: response.statusCode,
      houses: houses,
      message: json['message'],
    );
  }
}
