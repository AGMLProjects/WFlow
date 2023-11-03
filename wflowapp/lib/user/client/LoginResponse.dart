import 'dart:convert';

import 'package:http/http.dart';

class LoginResponse {
  final int code;
  final String key;
  final String message;

  const LoginResponse(
      {required this.code, required this.key, required this.message});

  factory LoginResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    int code = response.statusCode;
    String key = '';
    String message = '';
    if (code == 200) {
      key = json['key'];
    }
    if (code == 400) {
      message = 'Invalid credentials';
    }
    if (code == 502) {
      message = 'Service unavailable';
    }
    return LoginResponse(
      code: response.statusCode,
      key: key,
      message: message,
    );
  }
}
