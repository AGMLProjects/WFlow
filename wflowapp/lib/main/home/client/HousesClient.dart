import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'HousesResponse.dart';

class HousesClient {
  final String url;
  final String path;

  const HousesClient({required this.url, required this.path});

  Future<HousesResponse> getHouses(String token) async {
    String body = jsonEncode(<String, String>{'token': token});
    log(name: 'HTTP', 'Calling $path with body: $body');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HousesResponse.fromResponse(response);
  }
}
