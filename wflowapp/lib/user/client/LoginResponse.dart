import 'dart:convert';

import 'package:http/http.dart';

class LoginResponse {
  final int code;
  final String token;
  final String message;

  const LoginResponse(
      {required this.code, required this.token, required this.message});

  factory LoginResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    return LoginResponse(
      code: response.statusCode,
      token: json['token'],
      message: json['message'],
    );
  }
}
