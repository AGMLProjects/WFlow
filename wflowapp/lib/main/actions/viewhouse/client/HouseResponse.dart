import 'dart:convert';
import 'dart:developer';
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
    dynamic dhouse = json['house'];
    House house = House(
        id: dhouse['id'],
        name: dhouse['name'],
        totalConsumes: dhouse['totalConsumes'],
        location: dhouse['location']);
    return HouseResponse(
      code: response.statusCode,
      house: house,
      message: json['message'],
    );
  }
}
