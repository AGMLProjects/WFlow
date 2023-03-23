import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'HouseResponse.dart';

class HouseClient {
  final String url;
  String path;

  HouseClient({required this.url, this.path = ''});

  Future<HouseResponse> getHouse(String key) async {
    log(name: 'HTTP', 'Calling $path');
    final response = await http.get(Uri.parse(url + path),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $key'
        });
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HouseResponse.fromResponse(response);
  }
}
