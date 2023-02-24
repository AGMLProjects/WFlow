import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:wflowapp/main/home/model/House.dart';

class HousesResponse {
  final int code;
  final List<House> houses;

  const HousesResponse({required this.code, required this.houses});

  factory HousesResponse.fromResponse(Response response) {
    List<dynamic> dhouses = jsonDecode(response.body);
    List<House> houses = [];
    for (var dhouse in dhouses) {
      House house = House(
          house_id: dhouse['house_id'],
          user_id: dhouse['user_id'],
          total_liters: dhouse['total_liters'],
          total_gas: dhouse['total_gas'],
          future_total_liters: dhouse['future_total_liters'],
          future_total_gas: dhouse['future_total_gas'],
          name: dhouse['name'],
          address: dhouse['address'],
          city: dhouse['city'],
          house_type: dhouse['house_type']);
      houses.add(house);
    }
    return HousesResponse(
      code: response.statusCode,
      houses: houses,
    );
  }
}
