import 'dart:convert';
import 'package:http/http.dart';
import 'package:wflowapp/main/actions/viewhouse/model/House.dart';
import 'package:wflowapp/main/actions/viewhouse/model/HouseResponse.dart';

class HouseResponseAPI {
  final int code;
  final HouseResponse houseResponse;

  const HouseResponseAPI({required this.code, required this.houseResponse});

  factory HouseResponseAPI.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    HouseResponse houseResponse = HouseResponse.fromJson(json);
    return HouseResponseAPI(
      code: response.statusCode,
      houseResponse: houseResponse,
    );
  }
}
