import 'dart:developer';
import 'package:http/http.dart' as http;

import 'HousesResponse.dart';

class HousesClient {
  final String url;
  final String path;

  const HousesClient({required this.url, required this.path});

  Future<HousesResponse> getHouses(String key) async {
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $key'
      },
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HousesResponse.fromResponse(response);
  }
}
