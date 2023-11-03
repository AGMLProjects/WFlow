import 'dart:convert';
import 'package:http/http.dart';

class AddDeviceResponse {
  final int code;
  final String message;

  const AddDeviceResponse({required this.code, required this.message});

  factory AddDeviceResponse.fromResponse(Response response) {
    dynamic body = jsonDecode(response.body);
    return AddDeviceResponse(
      code: response.statusCode,
      message: body['message'],
    );
  }
}
