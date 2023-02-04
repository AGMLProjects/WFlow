import 'dart:convert';
import 'package:http/http.dart';

class EditHouseResponse {
  final int code;
  final String house;
  final String message;

  const EditHouseResponse(
      {required this.code, required this.house, required this.message});

  factory EditHouseResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    String house = json['house'];
    return EditHouseResponse(
      code: response.statusCode,
      house: house,
      message: json['message'],
    );
  }
}
