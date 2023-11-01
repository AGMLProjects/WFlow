import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'HeaterActuatorResponseGet.dart';
import 'HeaterActuatorResponsePost.dart';

class HeaterActuatorClient {
  final String url;
  final String get_path;
  final String post_path;

  const HeaterActuatorClient(
      {required this.url, required this.get_path, required this.post_path});

  Future<HeaterActuatorResponseGet> getHeater(String key, int sensor_id) async {
    Map<String, dynamic> map = {'sensor_id': sensor_id};
    String body = jsonEncode(map);
    Uri uri = Uri.https(url, get_path);
    log(name: 'HTTP', 'Calling $uri');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $key',
        },
        body: body);
    log(name: 'HTTP', 'Response from $get_path: ${response.statusCode}');
    return HeaterActuatorResponseGet.fromResponse(response);
  }

  Future<HeaterActuatorResponsePost> setHeater(
      String key,
      int sensor_id,
      bool status,
      bool automatic,
      List<double> temperatures,
      List<DateTime> starts,
      List<DateTime> ends) async {
    List<String> time_start = starts.map((d) {
      DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
      return format.format(d);
    }).toList();
    List<String> time_end = ends.map((d) {
      DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
      return format.format(d);
    }).toList();
    Map<String, dynamic> values = {
      'status': status,
      'temperature': temperatures,
      'time_start': time_start,
      'time_end': time_end,
      'automatic': automatic
    };
    Map<String, dynamic> map = {
      'sensor_id': sensor_id,
      'start_timestamp': DateTime.now().toString(),
      'end_timestamp': DateTime.now().toString(),
      'values': values
    };
    String body = jsonEncode(map);
    Uri uri = Uri.https(url, post_path);
    log(name: 'HTTP', 'Calling $uri');
    log(name: 'HTTP', 'Body: $body');
    final response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Token $key'
        },
        body: body);
    log(name: 'HTTP', 'Response from $post_path: ${response.statusCode}');
    return HeaterActuatorResponsePost.fromResponse(response);
  }
}
