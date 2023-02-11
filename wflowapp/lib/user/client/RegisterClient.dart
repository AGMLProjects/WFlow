import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'RegisterResponse.dart';

class RegisterClient {
  final String url;
  final String path;

  const RegisterClient({required this.url, required this.path});

  Future<RegisterResponse> register(String email, String password) async {
    String bodyForDebug =
        jsonEncode(<String, String>{'email': email, 'password': '***'});
    String body =
        jsonEncode(<String, String>{'email': email, 'password': password});
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    log(name: 'HTTP', 'Body: $bodyForDebug');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return RegisterResponse.fromResponse(response);
  }
}
