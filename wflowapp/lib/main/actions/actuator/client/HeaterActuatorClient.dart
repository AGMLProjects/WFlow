import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/main/actions/actuator/client/HeaterActuatorResponse.dart';

class HeaterActuatorClient {
  final String url;
  final String path;

  const HeaterActuatorClient({required this.url, required this.path});

  Future<HeaterActuatorResponse> getHeater(
      String key, int sensorId, int deviceId) async {
    Map<String, dynamic> map = {'sensor_id': sensorId, 'device_id': deviceId};
    String body = jsonEncode(map);
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $key'
        },
        body: body);
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HeaterActuatorResponse.fromResponse(response);
  }

  Future<HeaterActuatorResponse> setHeater(
      String key,
      int sensorId,
      int deviceId,
      bool active,
      bool automatic,
      List<int> temperatures,
      List<DateTime> starts,
      List<DateTime> ends) async {
    Map<String, dynamic> map = {
      'sensor_id': sensorId,
      'device_id': deviceId,
      'active': active,
      'automatic': automatic,
      'temperatures': temperatures,
      'starts': starts,
      'ends': ends
    };
    String body = jsonEncode(map);
    Uri uri = Uri.https(url, path);
    log(name: 'HTTP', 'Calling $uri');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $key'
        },
        body: body);
    log(name: 'HTTP', 'Response from $path: ${response.statusCode}');
    return HeaterActuatorResponse.fromResponse(response);
  }
}
