import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'HouseResponse.dart';

class HouseClient {
  final String url;
  final String path;

  const HouseClient({required this.url, required this.path});

  Future<HouseResponse> getHouse(String token, String id) async {
    String body = jsonEncode(<String, String>{'key': token, 'id': id});
    log(name: 'HTTP', 'Calling $path with body: $body');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HouseResponse.fromResponse(response);
  }
}
