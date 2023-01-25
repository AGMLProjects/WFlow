import 'dart:convert';
import 'package:http/http.dart' as http;

import 'HousesResponse.dart';

class HomePageClient {
  final String url;
  final String path;

  const HomePageClient({required this.url, required this.path});

  Future<HousesResponse> getHouses(String token) async {
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'token': token}),
    );
    return HousesResponse.fromResponse(response);
  }
}
