import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/config/AppConfig.dart';

import 'DiscoverResponse.dart';

class DiscoverClient {
  final String url;
  final String path;

  const DiscoverClient({required this.url, required this.path});

  Future<DiscoverResponse> getStatistics(
      String key, String region, String city, String statistic) async {
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
    return DiscoverResponse.fromResponse(response);
  }
}
