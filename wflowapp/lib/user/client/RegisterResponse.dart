import 'dart:convert';

import 'package:http/http.dart';

class RegisterResponse {
  final int code;
  final String token;
  final String message;

  const RegisterResponse(
      {required this.code, required this.token, required this.message});

  factory RegisterResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    return RegisterResponse(
      code: response.statusCode,
      token: json['token'],
      message: json['message'],
    );
  }
}
