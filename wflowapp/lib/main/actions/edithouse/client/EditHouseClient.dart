import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/edithouse/client/EditHouseResponse.dart';

class EditHouseClient {
  final String url;
  String path;

  EditHouseClient({required this.url, this.path = ''});

  Future<EditHouseResponse> editHouse(String key, int house, String name,
      String city, String address, String type) async {
    Uri uri = Uri.https(url, path);
    String body = jsonEncode(<String, dynamic>{
      'house_id': house,
      'name': name,
      'city': city,
      'address': address,
      'house_type': type,
      'total_liters': 0.0,
      'total_gas': 0.0,
      'future_total_liters': 0.0,
      'future_total_gas': 0.0
    });
    log(name: 'HTTP', 'Calling $path');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.put(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $key'
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return EditHouseResponse.fromResponse(response);
  }
}
