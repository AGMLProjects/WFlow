import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../model/DiscoverResponseAllRegion.dart';

class DiscoverClientAllRegion {
  final String url;
  final String path;

  const DiscoverClientAllRegion({required this.url, required this.path});

  Future<DiscoverResponseAllRegion> getStatistics() async {
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    });
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return DiscoverResponseAllRegion.fromResponse(response);
  }
}
