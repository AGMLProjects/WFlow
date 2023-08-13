import 'dart:convert';
import 'package:http/http.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';

class HouseResponse {
  final int code;
  final House house;

  const HouseResponse({required this.code, required this.house});

  factory HouseResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    House house = House.fromJson(json);
    return HouseResponse(
      code: response.statusCode,
      house: house,
    );
  }
}
