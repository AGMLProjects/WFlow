import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/edithouse/client/EditHouseResponse.dart';

class EditHouseClient {
  final String url;
  final String path;

  const EditHouseClient({required this.url, required this.path});

  Future<EditHouseResponse> editHouse(
      String token, String id, String name, String location) async {
    String body = jsonEncode(<String, String>{
      'token': token,
      'id': id,
      'name': name,
      'location': location
    });
    log(name: 'HTTP', 'Calling $path with body: $body');
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return EditHouseResponse.fromResponse(response);
  }
}
