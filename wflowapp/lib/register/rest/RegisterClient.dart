import 'dart:convert';
import 'package:http/http.dart' as http;

import 'RegisterResponse.dart';

class RegisterClient {
  final String url;
  final String path;

  const RegisterClient({required this.url, required this.path});

  Future<RegisterResponse> register(String email, String password) async {
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    return RegisterResponse.fromResponse(response);
  }
}
