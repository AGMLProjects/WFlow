import 'dart:convert';
import 'package:http/http.dart' as http;

import 'HouseResponse.dart';

class HouseClient {
  final String url;
  final String path;

  const HouseClient({required this.url, required this.path});

  Future<HouseResponse> getHouse(String token, String id) async {
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'token': token, 'id': id}),
    );
    return HouseResponse.fromResponse(response);
  }
}
