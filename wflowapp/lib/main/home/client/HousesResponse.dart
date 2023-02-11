import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:wflowapp/main/home/model/House.dart';

class HousesResponse {
  final int code;
  final List<House> houses;

  const HousesResponse({required this.code, required this.houses});

  factory HousesResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    List<dynamic> _dhouses = json;
    List<House> houses = [];
    int FAKE_ID = 0;
    for (var _dhouse in _dhouses) {
      FAKE_ID++;
      House house = House(
          id: FAKE_ID.toString(),
          name: _dhouse['name'],
          total_expenses: _dhouse['total_expenses'],
          address: _dhouse['address'],
          city: _dhouse['city']);
      houses.add(house);
    }
    return HousesResponse(
      code: response.statusCode,
      houses: houses,
    );
  }
}
