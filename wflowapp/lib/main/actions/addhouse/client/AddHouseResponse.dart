import 'dart:convert';
import 'package:http/http.dart';
import 'package:wflowapp/main/home/model/House.dart';

class AddHouseResponse {
  final int code;
  final House house;

  const AddHouseResponse({required this.code, required this.house});

  factory AddHouseResponse.fromResponse(Response response) {
    dynamic dhouse = jsonDecode(response.body);
    House house = House(
      house_id: dhouse['house_id'],
      user_id: dhouse['user_id'],
      name: dhouse['name'],
      country: dhouse['country'],
      region: dhouse['region'],
      city: dhouse['city'],
      house_type: dhouse['house_type'],
      address: dhouse['address'],
    );

    return AddHouseResponse(
      code: response.statusCode,
      house: house,
    );
  }
}
