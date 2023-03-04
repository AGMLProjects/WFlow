import 'dart:convert';
import 'package:http/http.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';

class HouseResponse {
  final int code;
  final House house;
  final String message;

  const HouseResponse(
      {required this.code, required this.house, required this.message});

  factory HouseResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    dynamic dhouse = json['house'];
    House house = House.fromJson(dhouse);
    return HouseResponse(
      code: response.statusCode,
      house: house,
      message: json['message'],
    );
  }
}
