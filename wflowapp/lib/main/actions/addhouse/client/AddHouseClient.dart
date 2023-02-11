import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/addhouse/client/AddHouseResponse.dart';

class AddHouseClient {
  final String url;
  final String path;

  const AddHouseClient({required this.url, required this.path});

  Future<AddHouseResponse> addHouse(
      String token, String name, String location) async {
    String body = jsonEncode(
        <String, String>{'key': token, 'name': name, 'location': location});
    log(name: 'HTTP', 'Calling $path with body: $body');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return AddHouseResponse.fromResponse(response);
  }
}
