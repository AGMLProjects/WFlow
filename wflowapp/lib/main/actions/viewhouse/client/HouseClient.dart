import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/viewhouse/client/HouseResponseAPI.dart';
import 'package:wflowapp/main/actions/viewhouse/model/HouseResponse.dart';

class HouseClient {
  final String url;
  String path;

  HouseClient({required this.url, this.path = ''});

  Future<HouseResponseAPI> getHouse(String key) async {
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    final response = await http.get(uri, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token $key'
    });
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HouseResponseAPI.fromResponse(response);
  }
}
