import 'dart:convert';
import 'package:http/http.dart';

import 'House.dart';

class HouseResponse {
  final int code;
  final House house;
  final String message;

  const HouseResponse(
      {required this.code, required this.house, required this.message});

  factory HouseResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    dynamic _dhouse = json['house'];
    House house = House(
        id: _dhouse['id'],
        name: _dhouse['name'],
        totalConsumes: _dhouse['totalConsumes'],
        location: _dhouse['location']);
    return HouseResponse(
      code: response.statusCode,
      house: house,
      message: json['message'],
    );
  }
}
