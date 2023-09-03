import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

class HeaterActuatorResponse {
  final int code;
  final bool active;
  final bool automatic;
  final List<int> temperatures;
  final List<DateTime> starts;
  final List<DateTime> ends;

  HeaterActuatorResponse(
      {required this.code,
      required this.active,
      required this.automatic,
      required this.temperatures,
      required this.starts,
      required this.ends});

  factory HeaterActuatorResponse.fromResponse(Response response) {
    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      log(json.toString());
      HeaterActuatorResponse res = HeaterActuatorResponse(
          code: response.statusCode,
          active: json['active'],
          automatic: json['automatic'],
          temperatures: json['temperatures'],
          starts: json['starts'],
          ends: json['ends']);
      return res;
    } else {
      bool active = true, automatic = true;
      List<int> temperatures = [24, 26, 24];
      List<DateTime> starts = [
        DateTime(2023, 1, 1, 8, 0),
        DateTime(2023, 1, 1, 17, 30),
        DateTime(2023, 1, 1, 20, 0),
      ];
      List<DateTime> ends = [
        DateTime(2023, 1, 1, 8, 30),
        DateTime(2023, 1, 1, 18, 30),
        DateTime(2023, 1, 1, 21, 0),
      ];
      HeaterActuatorResponse res = HeaterActuatorResponse(
          code: 200,
          active: active,
          automatic: automatic,
          temperatures: temperatures,
          starts: starts,
          ends: ends);
      return res;
    }
  }
}
