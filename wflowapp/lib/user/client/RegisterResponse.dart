import 'dart:convert';

import 'package:http/http.dart';

class RegisterResponse {
  final int code;
  final String key;
  final String message;

  const RegisterResponse(
      {required this.code, required this.key, required this.message});

  factory RegisterResponse.fromResponse(Response response) {
    dynamic json = jsonDecode(response.body);
    int code = response.statusCode;
    String key = '';
    String message = '';
    if (code == 201) {
      key = json['key'];
    }
    if (code == 400) {
      message = 'Invalid credentials';
    }
    return RegisterResponse(
      code: response.statusCode,
      key: key,
      message: message,
    );
  }
}
