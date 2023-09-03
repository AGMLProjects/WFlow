import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:wflowapp/config/AppConfig.dart';
import 'package:wflowapp/main/actions/actuator/client/ShowerActuatorResponse.dart';

class ShowerActuatorClient {
  final String url;
  final String path;

  const ShowerActuatorClient({required this.url, required this.path});

  Future<ShowerActuatorResponse> activateShower(
      String key, int sensorId, int deviceId, double temperature) async {
    Map<String, dynamic> map = {
      'sensor_id': sensorId,
      'start_timestamp': '',
      'end_timestamp': '',
      'values': {'temperature': temperature},
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
    return ShowerActuatorResponse.fromResponse(response);
  }
}
