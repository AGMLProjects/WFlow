import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'LoginResponse.dart';

class LoginClient {
  final String url;
  final String path;

  const LoginClient({required this.url, required this.path});

  Future<LoginResponse> login(String email, String password) async {
    String bodyForDebug =
        jsonEncode(<String, String>{'email': email, 'password': '***'});
    String body =
        jsonEncode(<String, String>{'email': email, 'password': password});
    log(name: 'HTTP', 'Calling $path with body: $bodyForDebug');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return LoginResponse.fromResponse(response);
  }
}
