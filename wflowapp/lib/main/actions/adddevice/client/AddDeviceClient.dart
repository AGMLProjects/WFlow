import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/adddevice/client/AddDeviceResponse.dart';

class AddDeviceClient {
  final String url;
  final String path;

  const AddDeviceClient({required this.url, required this.path});

  Future<AddDeviceResponse> addDevice(
      String key, int house_id, String device_id, String name) async {
    Uri uri = Uri.https(url, path);
    String body = jsonEncode(<String, dynamic>{
      'device_id': device_id,
      'house_id': house_id,
      'name': name,
    });
    log(name: 'HTTP', 'Calling $path');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $key'
      },
      body: body,
    );
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return AddDeviceResponse.fromResponse(response);
  }
}
