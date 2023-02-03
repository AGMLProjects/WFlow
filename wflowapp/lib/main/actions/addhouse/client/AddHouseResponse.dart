import 'dart:convert';
import 'package:http/http.dart';

class AddHouseResponse {
  final int code;
  final String house;
  final String message;

  const AddHouseResponse(
      {required this.code, required this.house, required this.message});

  factory AddHouseResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    String house = json['house'];
    return AddHouseResponse(
      code: response.statusCode,
      house: house,
      message: json['message'],
    );
  }
}
