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
      dynamic total_liters = 0.0;
      if (dhouse['total_liters'] != null) {
        total_liters = dhouse['total_liters'];
      }
      dynamic total_gas = 0.0;
      if (dhouse['total_gas'] != null) {
        total_gas = dhouse['total_gas'];
      }
      dynamic future_total_liters = 0.0;
      if (dhouse['future_total_liters'] != null) {
        future_total_liters = dhouse['future_total_liters'];
      }
      dynamic future_total_gas = 0.0;
      if (dhouse['future_total_gas'] != null) {
        total_liters = dhouse['future_total_gas'];
      }
      House house = House(
          house_id: dhouse['house_id'],
          user_id: dhouse['user_id'],
          total_liters: total_liters,
          total_gas: total_gas,
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
