import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/mainpage/addhouse/rest/AddHouseResponse.dart';

class AddHouseClient {
  final String url;
  final String path;

  const AddHouseClient({required this.url, required this.path});

  Future<AddHouseResponse> addHouse(
      String token, String name, String location, String color) async {
    final response = await http.post(
      Uri.parse(url + path),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
        'name': name,
        'location': location,
        'color': color
      }),
    );
    return AddHouseResponse.fromResponse(response);
  }
}
