import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/discover/model/DiscoverResponseCityRegion.dart';

class DiscoverClientRegionCity {
  final String url;
  final String path;

  const DiscoverClientRegionCity({required this.url, required this.path});

  Future<DiscoverResponseCityRegion> getStatistics(
      String key, String region, String city, String type) async {
    Uri uri = Uri.https(url, path);
    String body = jsonEncode(<String, dynamic>{
      'region': region,
      'city': city,
      'type': type.toLowerCase()
    });
    log(name: 'HTTP', 'Calling $uri');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return DiscoverResponseCityRegion.fromResponse(response);
  }
}
