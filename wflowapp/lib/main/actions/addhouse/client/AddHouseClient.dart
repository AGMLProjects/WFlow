import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/addhouse/client/AddHouseResponse.dart';

class AddHouseClient {
  final String url;
  final String path;

  const AddHouseClient({required this.url, required this.path});

  Future<AddHouseResponse> addHouse(
      String key, String name, String city, String address, String type) async {
    String body = jsonEncode(<String, String>{
      'name': name,
      'city': city,
      'address': address,
      'type': type
    });
    log(name: 'HTTP', 'Calling $path');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $key'
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return AddHouseResponse.fromResponse(response);
  }
}
