import 'dart:convert';
import 'package:http/http.dart' as http;

import 'LoginResponse.dart';

class LoginClient {
  final String url;
  final String path;

  const LoginClient({required this.url, required this.path});

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(
          'https://49c13ba9-40e6-426b-be3c-21acf8b4f1d4.mock.pstmn.io/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed');
    }
  }
}
