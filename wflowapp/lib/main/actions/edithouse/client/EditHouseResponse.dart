import 'dart:convert';
import 'package:http/http.dart';
import 'package:wflowapp/main/home/model/House.dart';

class EditHouseResponse {
  final int code;
  final House house;

  const EditHouseResponse({required this.code, required this.house});

  factory EditHouseResponse.fromResponse(Response response) {
    dynamic dhouse = jsonDecode(response.body);
    House house = House(
        house_id: dhouse['house_id'],
        user_id: dhouse['user_id'],
        name: dhouse['name'],
        address: dhouse['address'],
        city: dhouse['city'],
        house_type: dhouse['house_type']);
    return EditHouseResponse(
      code: response.statusCode,
      house: house,
    );
  }
}
