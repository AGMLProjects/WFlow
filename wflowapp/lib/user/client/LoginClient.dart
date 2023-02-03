import 'dart:convert';
import 'package:http/http.dart' as http;

import 'LoginResponse.dart';

class LoginClient {
  final String url;
  final String path;

  const LoginClient({required this.url, required this.path});

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    return LoginResponse.fromResponse(response);
  }
}
